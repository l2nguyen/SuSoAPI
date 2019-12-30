interview_stats <- function(ids=NULL, server="", user="", password=""){

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

  server <- tolower(trimws(server))

  # check server exists
  server_url <- paste0("https://", server, ".mysurvey.solutions")

  # Check server exists
  tryCatch(httr::http_error(server_url),
           error=function(err) {
             err$message <- paste(server, "is not a valid server.")
             stop(err)
           })

  # build base URL for API
  api_url <- paste0(server_url, "/api/v1")

  # function to get stats for one interview
  single_int <- function(id, base_url, user_id, pass){
    # build api endpoint for interview stats
    endpoint <- paste0(base_url, "/interviews/", id, "/stats")

    resp <- httr::GET(endpoint, authenticate(user_id, pass))

    if (httr::status_code(resp)==200){
      int_stats <- jsonlite::fromJSON(content(resp, as = "text"), flatten = TRUE)
      return(int_stats)
    } else if (httr::status_code(resp)==401){
      message("Invalid login or password.")
    } else {
      message("Error getting stats for interview: ", id)
    }
  }

  all_stats_df <- dplyr::bind_rows(lapply(ids, single_int, api_url,
                                          user, password)) %>%
    # rename output columns to be consistent with export data
    dplyr::rename(interview__id = InterviewId, interview__key = InterviewKey) %>%
    dplyr::select(interview__id, interview__key, everything())

  return(all_stats_df)
}
