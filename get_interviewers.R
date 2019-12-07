get_interviewers <- function(super_names=NULL, super_ids=NULL,
                             server, user, password){

  load_pkg <- function(x) {
    if (!require(x, character.only = TRUE)) {
      install.packages(x, repos = "https://cloud.r-project.org/", dep = TRUE)
    }
    library(x, character.only = TRUE)
  }

  # required packages
  load_pkg("httr")
  load_pkg("jsonlite")
  load_pkg("dplyr")
  load_pkg("here")

  # load get_supers function
  source(here::here("get_supers.R"))

  #===> BASIC CHECKS
  # check that server, login, password, and data type are non-missing
  for (x in c("server", "user", "password")) {
    if (!is.character(get(x))) {
      stop(x, "has to be a string.")
    }
    if (nchar(get(x)) == 0) {
      stop(paste("The following parameter is not specified:", x))
    }
  }

  # check that not both qx name and template id is specified
  if(!is.null(super_names) & !is.null(super_ids)){
    stop("Specify only either name or user IDs for supervisors.")
  }

  # build base URL for API
  server <- tolower(trimws(server))

  # build base URL for API
  api_url <- sprintf("https://%s.mysurvey.solutions/api/v1",
                     server)

  #==> GET DF OF SUPERVISORS
  all_supers <- get_supers(server, user, password)

  #=== HELPER FUNCTION ====#
  # function to check if supervisor exists
  sup_exists <- function(supervisor, data, stype="name"){
    # set variable name
    var_name <- ifelse(stype=="name", "SuperName", "SuperId")
    if (!(supervisor %in% data[[var_name]])){
      stop("User does not exist: ", supervisor)
    }
  }

  # function get supervisor ID if given name
  get_sup_id <- function(sup_name, data){
    id <- dplyr::filter(data, SuperName==sup_name)$SuperId
    return(id)
  }

  # function to make API call for interiewers for a supervisor
  get_ints <- function(sup_id, base_url, user_id, pass){
    int_endpoint <- paste0(base_url, "/supervisors/", sup_id, "/interviewers")
    data <- httr::GET(int_endpoint, authenticate(user_id, pass),
                      query= list(limit=40))

    if (httr::status_code(data) == 200) {
      # save the list of imported templates from the API as a data frame
      inters <- jsonlite::fromJSON(content(data, as = "text"), flatten = TRUE)

      # get total counts
      total_count <- inters$TotalCount
      # data frame of interviewers
      ints_df <- inters$Users
    } else if (httr::status_code(data) == 401) {# login error
      stop("Incorrect username or password. Check login credentials.")
    } else {# any other error
      stop("Encountered issue with status code ", status_code(data))
    }

    if (total_count == 0 | is.null(total_count)) {
      all_ints_df <- data.frame(
        IsLocked = NA,
        CreationDate = NA,
        DeviceId = NA)
    } else if (total_count>0 & total_count<=40){
      all_ints_df <- ints_df
    } else{
      df_list = list(ints_df)
      # use limit to figure out number of calls to make
      limit <- inters$Limit
      n_calls <- ceiling(total_count/limit)

      for (i in 2:n_calls){
        loop_resp <- httr::GET(int_endpoint, authenticate(user_id, pass),
                               query= list(limit=40, offset=i))

        if (status_code(loop_resp) == 200) {
          # process response
          flat_loop <- jsonlite::fromJSON(content(loop_resp, as = "text"),
                                          flatten = TRUE)
          loop_df <- flat_loop$Users
          # append to existing list of df
          df_list[[i]] <- loop_df
        } else {# any other error
          stop("Encountered issue with status code ", status_code(loop_resp))
        }
      }

      # bind all data frames together to get full list
      all_ints_df <- dplyr::bind_rows(df_list)
    }

    # add supervisor Id
    all_ints_df$SuperId <- sup_id

    # return data frame of interviewers for supervisor
    return(all_ints_df)
  }

  #======== GET FULL LIST OF INTERVIEWERS ==========#
  # check all supervisor names or IDs specified exist
  if (is.null(super_names) & is.null(super_ids)) {
    ids_to_call <- dplyr::pull(all_supers, SuperId)
  } else if (length(super_names)>0) {
    invisible(sapply(super_names, sup_exists, data=all_supers, stype="name"))
    # get IDs associated with users
    ids_to_call <- sapply(super_names, get_sup_id, data = all_supers)
  } else if (length(super_ids)>0) {
    invisible(sapply(super_ids, sup_exists, data=all_supers, stype="id"))
    # set IDs to get interviewers for
    ids_to_call <- super_ids
  } else {
    stop("Specify only either name or user IDs for supervisors.")
  }

  filtered_supers <- dplyr::filter(all_supers, SuperId %in% ids_to_call) %>%
    dplyr::select(SuperName, SuperId)

  # get full list of interviewers
  full_df_list <- lapply(ids_to_call, get_ints, base_url=api_url,
                         user_id=user, pass=password)
  # bind list into one big data frame
  all_interviewers <- dplyr::bind_rows(full_df_list) %>%
    dplyr::rename(InterName = UserName, InterId = UserId) %>%
    # add supervisor information
    dplyr::inner_join(filtered_supers, by="SuperId") %>%
    # rearrange columns
    dplyr::select(InterName, InterId, SuperName, SuperId, everything())

  return(all_interviewers)
}