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

get_qx_id <- function(server, 
                    qx_name = "",
                    user = "APIuser",
                    password = "Password123")
{
  
  
  # Stop and give an error if no questionnaire name provided
  if (qx_name == "") {
    stop("Error: Please provide the name of the questionnaire.")
  } 
  else {
    #Get data about questionnaires on server
    get_qx(server, user, password)
    # return ID associated with the questionnaire name
    return(unique(qnrList_all$QuestionnaireId[qnrList_all$Title == Qxname]))
  }
}
