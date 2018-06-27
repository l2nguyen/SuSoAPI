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
  # Required packages
  require(stringr)
  require(jsonlite)
  require(httr)
  require(lubridate)

  # First, get questionnaire information from server
  get_qx(server, user, password)

  # trim white space before
  qx_name <- str_trim(qx_name)

  # get all versions of the questionnaire on the server
  allVers <- qnrList_all$Version[qnrList_all$Title == qx_name]

  # Export data for each version if more than one version
  for (i in allVers) {
    dl_one(
      server,
      user,
      password,
      qx_name,
      version = i,
      export_type,
      folder
    )
  }
}