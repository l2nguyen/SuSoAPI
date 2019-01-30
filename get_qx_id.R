#------------------------------------------------------------------------#
#-------- GET THE TEMPLATE ID TO THE PROVIDED QUESTIONNAIRE NAME --------#
#------------------------------------------------------------------------#
# Args:
# server: server prefix
# Qxname: Name of the questionnaire of interst
# user: API user ID, default is API user
# password: password for API user, default is Password 123
#
# Returns:
# The template ID associated with the name of the questionnaire

get_qx_id <- function(
                    	qx_name = "",
                    	ignore.case = TRUE,
                    	server,
                    	user = "APIuser",
                    	password = "Password123")
{
  # require packages
  require("httr")
  require("jsonlite")
  require("dplyr")
  require("stringr")

  if (ignore.case) {
    qx_name <- str_to_upper(str_trim(qx_name))
    qnrList_all$Title <- str_to_upper(str_trim(qnrList_all$Title))
  }

  # check if questionnaire is imported on server
  if (qx_name %in% qnrList_all$Title) {
    # return ID associated with questionnaire name
    return(unique(qnrList_all$QuestionnaireId[qnrList_all$Title == qx_name]))
  } else if (qx_name == "") {
    # give error
    stop("Error: Please provide the name of the questionnaire.")
  } else {
    stop("Error: Please check the questionnaire name.")
  }
}
