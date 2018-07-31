#----------------------------------------------------#
#-------------- EXPORT ALL VERSIONS -----------------#
#----------------------------------------------------#
# Args:
# server: server prefix
# user: API user ID, default is API user
# password: password for API user, default is Password 123
# qx_name: Name of the questionnaire of interest
# export type: the data type that you would like to export
# options are tabular, stata, spss, binary, paradata
# folder: the directory you would like to export the data into. Use '\\' instead of '\'
#
# Returns:
# The exported data of all the versions. Each version will have its own zip file and folder

dl_allVers <- function(server,
                       user = "APIuser",  # API user ID
                       password = "Password123",  # password
                       qx_name,  # Name of questionnaire (not template ID)
                       export_type = "tabular", # export type
                       folder   # directory for data download
)
{
  source("dl_one.R")

  # Required packages
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

  # First, get questionnaire information from server
  get_qx(server, user, password)

  # get template ID of provided template
  template <- get_qx_id(server, str_trim(qx_name), user, password)

  # get all versions of the questionnaire on the server based on template ID
  allVers <- qnrList_all$Version[qnrList_all$QuestionnaireId == template]

  # Export data for each version if more than one version
  for (i in allVers) {
    dl_one(
      qx_name = qx_name,
      version = i,
      export_type = export_type,
      folder = folder,
      unzip = TRUE,
      server = server,
      user = user,
      password = password
    )
  }
}