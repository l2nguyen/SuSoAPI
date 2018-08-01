#-------------------------------------------------------#
#------- DOWNLOAD ALL TEMPLATE WITH SIMILAR NAMES ------#
#-------------------------------------------------------#
# Args:
# server: server prefix
# user: API user ID, default is API user
# password: password for API user, default is Password 123
# pattern: the pattern that you would like to match. This can be the questionnaire name.
# from.start: user can choose to start matching from the beginning or the end
# export type: the data type that you would like to export
# options are tabular, stata, spss, binary, paradata
# folder: the directory you would like to export the data into. Use '/' instead of '\'
#
# Returns:
# The exported data from all templates with similar names.
# Each template will have its own zip file and folder
#

dl_similar <- function(
                       pattern,  # Name of questionnaire (not template ID). Can use regex
                       exclude = NULL, # words to exclude, can be list
                       ignore.case = TRUE,  # to ignore case in filter
                       export_type = "tabular", # export type
                       folder,   # directory for data download
                       unzip = TRUE, # option to unzip after download
                       server,
                       user = "APIuser",  # API user ID
                       password = "Password123"  # password
)
{
  source("dl_one.R")

  # Load required packages
  load_pkg <- function(x) {
    if (!require(x, character.only = TRUE)) {
      install.packages(x, repos = 'https://cloud.r-project.org/', dep = TRUE)
    }
    library(x, character.only = TRUE)
  }

  load_pkg('stringr')
  load_pkg('jsonlite')
  load_pkg('httr')
  load_pkg('lubridate')

  # -------------------------------------------------------------
  # check function inputs
  # -------------------------------------------------------------

  # check that server, login, password, and data type are non-missing
  for (x in c("server", "login", "password", "export_type", "folder")) {
    if (!is.character(get(x))) {
      stop("Check that the parameters in the data are the correct data type.")
    }
    if (nchar(get(x)) == 0) {
      stop(paste("The following parameter is not specified in the program:", x))
    }
  }

  # Check if it is a valid data type
  if ((tolower(export_type) %in% c("tabular", "stata", "spss", "binary", "paradata")) == FALSE) {
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

  # case sensitivity option
  if (ignore.case) {
    pattern <- str_to_upper(str_trim(pattern))
    exclude <- str_to_upper(str_trim(exclude))
    qnrList_all$Title <- str_to_upper(str_trim(qnrList_all$Title))
  }

  # make initial download list based on pattern
  dl_list <- filter(qnrList_all, str_detect(Title, pattern))

  # filter download list to exclude titlesi n the list of words to exclude
  if (length(exclude) == 1) {
    dl_list <- filter(dl_list, !(str_detect(Title, exclude)))
  }
  if (length(exclude) > 1) {
    dl_list <- filter(dl_list, !(str_detect(Title, paste(exclude, collapse = "|"))))
  }

  for (qnr in seq_len(nrow(dl_list))) {
      # download all items in a list
      dl_one(
        qx_name = dl_list$Title[qnr],
        version = dl_list$Version[qnr],
        export_type = export_type,
        folder = folder,
        unzip = TRUE,
        server = server,
        user = user,
        password = password
      )
  }
}


