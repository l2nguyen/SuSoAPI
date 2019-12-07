get_supers <- function(server, user, password) {

  load_pkg <- function(x) {
    if (!require(x, character.only = TRUE)) {
      install.packages(x, repos = 'https://cloud.r-project.org/', dep = TRUE)
    }
    library(x, character.only = TRUE)
  }

  # required packages
  load_pkg("httr")
  load_pkg("jsonlite")
  load_pkg("dplyr")

  # check that server, user, password are non-missing and strings
  for (x in c("server", "user", "password")) {
    if (!is.character(get(x))) {
      stop(x, "has to be a string.")
    }
    if (nchar(get(x)) == 0) {
      stop(paste("The following parameter is not specified in the program:", x))
    }
  }

  # build base URL for API
  server <- tolower(trimws(server))

  # build base URL for API
  api_url <- sprintf("https://%s.mysurvey.solutions/api/v1",
                     server)

  # build query
  endpoint <- paste0(api_url, "/supervisors")

  # initial call to test API works
  data <- httr::GET(endpoint, authenticate(user, password),
                    query= list(limit=40))

  # if API call works, get supervisor information
  if (httr::status_code(data) == 200) {
    # save the list of imported templates from the API as a data frame
    sups <- jsonlite::fromJSON(content(data, as = "text"), flatten = TRUE)
    super_df <- sups$Users
    df_list <- list(super_df)
    # get total count for iteration
    total_count <- sups$TotalCount
  } else if (httr::status_code(data) == 401) {# login error
    stop("Incorrect username or password. Check login credentials.")
  } else {# any other error
    stop("Encountered issue with status code ", status_code(data))
  }

  # if less than 40, return only data frame in list
  if (total_count<=40){
    sups_df <- df_list[[1]]
  } else{
    # use limit to figure out number of calls to make
    limit <- sups$Limit
    n_calls <- ceiling(total_count/limit)

    for (i in 2:n_calls){
      loop_resp <- httr::GET(endpoint, authenticate(user, password),
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
    # bind all dataframes with supervisor info together
    sups_df <- dplyr::bind_rows(df_list) %>%
      dplyr::select(UserName, UserId, IsLocked, CreationDate, DeviceId) %>%
      dplyr::rename(SuperId = UserId, SuperName = UserName)
  }
  # return data frame with supervisors
  return(sups_df)
}
