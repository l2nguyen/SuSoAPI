get_interviewers <- function(supers_name=NULL, supers_id=NULL,
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
  if(!is.null(supers_name) & !is.null(supers_id)){
    stop("Specify only either name or user IDs for supervisors.")
  }

  # build base URL for API
  server <- tolower(trimws(server))

  # build base URL for API
  api_url <- sprintf("https://%s.mysurvey.solutions/api/v1",
                     server)

  #==> GET DF OF SUPERS
  all_supers <- get_supers(server, user, password)

  #=== HELPER FUNCTION ====#
  # function to check if supervisor exists
  sup_exists <- function(supervisor, data, stype="name"){
    # set variable name
    var_name <- ifelse(stype=="name", "UserName", "UserId")
    if (!(supervisor %in% data[[var_name]])){
      stop("User does not exist: ", supervisor)
    }
  }

  # function get supervisor ID if given name
  get_sup_id <- function(sup_name, data){
    id <- dplyr::filter(data, UserName==sup_name)$UserId
    return(id)
  }

  # function to make API call for interiewers for a supervisor
  get_ints <- function(sup_id, base_url, user_id, pass){
    int_endpoint <- paste0(base_url, "/supervisors/", sup_id, "/interviewers")
    print(int_endpoint)
    data <- httr::GET(int_endpoint, authenticate(user_id, pass),
                      query= list(limit=40))

    if (httr::status_code(data) == 200) {
      # save the list of imported templates from the API as a data frame
      inters <- jsonlite::fromJSON(content(data, as = "text"), flatten = TRUE)

      df_list <- list(ints_df)
      # get total counts
      total_count <- inters$TotalCount
    } else if (httr::status_code(data) == 401) {# login error
      stop("Incorrect username or password. Check login credentials.")
    } else {# any other error
      stop("Encountered issue with status code ", status_code(data))
    }

    # if less than 40, return only data frame in list
    if (total_count<=40){
      all_ints_df <- df_list[[1]]
    } else{
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
    }

    all_ints_df <- dplyr::bind_rows(df_list)

    # return data frame of interviewers for supervisor
    return(all_ints_df)
  }

  #======== GET FULL LIST OF INTERVIEWERS ==========#
  # check all supervisor names or IDs specified exist
  if (length(supers_name)>0){
    invisible(sapply(supers_name, sup_exists, data=all_supers, stype="name"))
    # get IDs associated with users
    ids_to_call <- sapply(supers_name, get_sup_id, data = all_supers)
  } else {
    invisible(sapply(supers_id, sup_exists, data=all_supers, stype="id"))
    # set IDs to get interviewers for
    ids_to_call <- supers_id
  }

  full_df_list <- list()
  for (val in ids_to_call) {
    print(val)
    full_df_list <- c(full_df_list, get_ints(val, api_url, user, password))
  }

  all_interviewers <- dplyr::bind_rows(full_df_list)

  return(all_interviewers)
}