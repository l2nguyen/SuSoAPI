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

dl_similar <- function(server,
                       user = "APIuser",  # API user ID
                       password = "Password123",  # password
                       pattern,  # Name of questionnaire (not template ID),
                       from.start = TRUE, # match from the beginning. If false, it will match from end
                       export_type = "tabular", # export type
                       folder   # directory for data download
)
{
  source("dl_one.R")

  # Load required packages
  library("stringr")
  library("jsonlite")
  library("httr")
  library("lubridate")

  # First, get questionnaire information from server
  get_qx(server, user, password)

  # Make list of templates to download data for
  if (from.start) {# If starting from the beginning
    qnrList_all %>% filter(str_detect(Title, paste0("^", pattern))) -> dl_list
  } else {# if starting from end
    qnrList_all %>% filter(str_detect(Title, paste0(pattern, "$"))) -> dl_list
  }

  for (qnr in 1:nrow(dl_list)) {

      # download all items in a list
      dl_one(
        server,
        user,
        password,
        qx_name = dl_list$Title[qnr],
        version = dl_list$Version[qnr],
        export_type,
        folder
      )
  }
}


