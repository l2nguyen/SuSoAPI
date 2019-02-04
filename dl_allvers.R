#----------------------------------------------------#
#-------------- EXPORT ALL VERSIONS -----------------#
#----------------------------------------------------#

dl_allVers <- function(
                       qx_name,  # Name of questionnaire (not template ID)
                       keep = NULL,
                       drop = NULL,
                       ignore.case = TRUE,  # to ignore case in qx name
                       export_type = "tabular", # export type
                       folder,   # directory for data download
                       unzip = TRUE, # whether to unzip or not
                       server,
                       user = "APIuser",  # API user ID
                       password = "Password123",  # password
                       tries = 10 # number of times to check for export
)
{

  # -------------------------------------------------------------
  # Load all necessary functions and require packages
  # -------------------------------------------------------------
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
  load_pkg('here')

  source(here("get_qx.R"))
  source(here("dl_one.R"))

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

  # check that user did not specify both drop and keep
  if (!is.null(keep) && !is.null(drop)) {
    stop("Specify keep or drop. Cannot specify both.")
  }

  # -------------------------------------------------------------
  # Download data
  # -------------------------------------------------------------

  # First, get questionnaire information from server
  get_qx(server, user = user, password = password)

  if (ignore.case) {
    qx_name <- str_to_upper(str_trim(qx_name))
    qnrList_all$Title <- str_to_upper(str_trim(qnrList_all$Title))
  }

  # get template ID of provided template
  template <- unique(qnrList_all$QuestionnaireId[qnrList_all$Title == qx_name])

  # get all versions of the questionnaire on the server based on template ID
  allVers <- qnrList_all$Version[qnrList_all$QuestionnaireId == template]

  # drop certain versions only if drop vector is specified
  if (!is.null(drop)) {
    allVers <- allVers[!(allVers %in% drop)]
  }

  # keep certain versions only if keep vector is specified
  if (!is.null(keep)) {
    allVers <- allVers[allVers %in% keep]
  }

  # Export data for each version if more than one version
  for (i in allVers) {
    dl_one(
      qx_name = qx_name,
      version = i,
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