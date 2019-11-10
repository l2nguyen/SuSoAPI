archive_asgmts <- function(ids = NULL, # assignment ID, can be vector
                           server, # server prefix
                           user, # API user username
                           password) # password for API user
{
  # -------------------------------------------------------------
  # Load all necessary functions and require packages
  # -------------------------------------------------------------

  load_pkg <- function(x) {
    if (!require(x, character.only = TRUE)) {
      install.packages(x, repos = 'https://cloud.r-project.org/', dep = TRUE)
    }
    require(x, character.only = TRUE)
  }

  load_pkg('dplyr')
  load_pkg('jsonlite')
  load_pkg('httr')

  # -------------------------------------------------------------
  # CHECK ALL INPUTS
  # -------------------------------------------------------------

  # check that server, login, password, and data type are non-missing
  for (x in c("server", "user", "password")) {
    if (!is.character(get(x))) {
      stop(x, "has to be a string.")
    }
    if (nchar(get(x)) == 0) {
      stop(paste("The following parameter is not specified in the program:", x))
    }
  }

  # check if all assignment IDs are numeric
  if (sum(sapply(suppressWarnings({as.numeric(ids)}), is.na)) > 0){
    stop("Assignment IDs must be a number.")
  } else {
    # if all are numeric, convert to numeric vector
    ids <- as.numeric(ids)
  }

  # -------------------------------------------------------------
  # Send API request
  # -------------------------------------------------------------

  # build base URL for API
  server <- tolower(trimws(server))

  api_url <- sprintf("https://%s.mysurvey.solutions/api/v1",
                     server)

  # function archive one assignment
  archive_id <- function(x, url=api_url){
    # build api endpoint
    endpoint <- paste0(url, "/assignments/", x, '/archive')

    resp <- httr::PATCH(endpoint, authenticate(user, password))

    if (httr::status_code(resp)==200){
      message("Successfully archived assignment #", x)
    } else{
      message("Error archiving assignment #", x)
    }
  }

  # archive all assignments in list
  # invisible to prevent sapply from printing to console
  invisible(sapply(ids, archive_id))
}
