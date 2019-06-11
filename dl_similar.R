#-------------------------------------------------------#
#------- DOWNLOAD ALL TEMPLATE WITH SIMILAR NAMES ------#
#-------------------------------------------------------#

dl_similar <- function(
                       pattern,  # pattern to search for. Can use regex. can be vector of strings
                       exclude = NULL, # words to exclude, can be vector of strings
                       export_type = "tabular", # export type
                       folder,   # directory for data download
                       unzip = TRUE, # option to unzip after download
                       server,
                       user = "APIuser",  # API user ID
                       password = "Password123",  # password
                       tries = 10
)
{
  # Load required packages
  load_pkg <- function(x) {
    if (!require(x, character.only = TRUE)) {
      install.packages(x, repos = 'https://cloud.r-project.org/', dep = TRUE)
    }
    require(x, character.only = TRUE)
  }

  load_pkg('stringr')
  load_pkg('jsonlite')
  load_pkg('httr')
  load_pkg('lubridate')
  load_pkg('here')

  source(here::here("get_qx.R"))
  source(here::here("dl_one.R"))

  # -------------------------------------------------------------
  # check function inputs
  # -------------------------------------------------------------

  # check that server, login, password, and data type are non-missing
  for (x in c("server", "user", "password", "export_type", "folder")) {
    if (!is.character(get(x))) {
      stop("Check that the parameters in the data are the correct data type.")
    }
    if (nchar(get(x)) == 0) {
      stop(paste("The following parameter is not specified in the program:", x))
    }
  }

  # Check if it is a valid data type
  if ((tolower(export_type) %in%
       c("tabular", "stata", "spss", "binary", "paradata")) == FALSE) {
    stop("Data type has to be one of the following: Tablular, STATA, SPSS, Binary, paradata")
  }

  # confirm that expected folders exist
  if (!dir.exists(folder)) {
    stop("Data folder does not exist in the expected location: ", folder)
  }

  # build base URL for API
  api_URL <- sprintf("https://%s.mysurvey.solutions/api/v1",
                     server)

  # confirm that server exists
  serverCheck <- try(http_error(api_URL), silent = TRUE)
  if (class(serverCheck) == "try-error") {
    stop("The following server does not exist. Check the server name:",
         "\n", api_URL)
  }

  # -------------------------------------------------------------
  # Download data
  # -------------------------------------------------------------

  # First, get questionnaire information from server
  get_qx(server, user, password)

  # make initial download list based on pattern
  if (length(pattern) == 1) {
    dl_list <- filter(qnrList_all, str_detect(Title, pattern))
  } else if (length(pattern) > 1) {
    dl_list <- filter(qnrList_all, str_detect(Title, paste(pattern, collapse = "|")))
  } else {
    stop("Pattern not specified.")
  }

  # filter download list to exclude titlesi n the list of words to exclude
  if (length(exclude) == 1) {
    dl_list <- filter(dl_list, !(str_detect(Title, exclude)))
  } else if (length(exclude) > 1) {
    dl_list <- filter(dl_list, !(str_detect(Title, paste(exclude, collapse = "|"))))
  }

  if (nrow(dl_list) == 0) {
    stop("Pattern and exclusion words did not result in any matches.")
  }

  for (qnr in seq_len(nrow(dl_list))) {
      # download all items in a list
      dl_one(
        qx_name = dl_list$Title[qnr],
        version = dl_list$Version[qnr],
        export_type = export_type,
        folder = folder,
        unzip = unzip,
        server = server,
        user = user,
        password = password,
        tries = tries
      )
  }
}
