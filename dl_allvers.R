#----------------------------------------------------#
#-------------- EXPORT ALL VERSIONS -----------------#
#----------------------------------------------------#

dl_allVers <- function(server,
                       user = "APIuser",  # API user ID
                       password = "Password123",  # password
                       qx_name,  # Name of questionnaire (not template ID)
                       export_type = "tabular", # export type
                       folder   # directory for data download
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