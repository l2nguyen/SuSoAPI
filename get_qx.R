# =============================================================================
# Get a list of all the templates imported on the server
# =============================================================================
# NOTE: This will save the information about templates
# currently on the server as a data frame

# Args:
# API_URL: URL for API
# user: API user ID
# password: password for API user
#
# Returns:
# A data frame that has all the information about the imported
# questionnaires on the server. This is a prettified version of the JSON response.

get_qx <- function(server, user, password) {
  # require packages
  require("httr")
  require("jsonlite")
  require("dplyr")

  # build base URL for API
  API_URL <- sprintf("https://%s.mysurvey.solutions/api/v1/",
                     server)

  # build query
  query <- paste0(API_URL, "questionnaires")

  # Send GET request to API
  data <- GET(query, authenticate(user, password),
              query = list(limit = 40, offset = 1))

  # If response code is 200, request was succesffuly processed
  if (status_code(data) == 200) {

    # save the list of imported templates from the API as a data frame
    qnrList <- fromJSON(content(data, as = "text"), flatten = TRUE)

    if (qnrList$TotalCount <= 40) {
      # if 40 questionnaires or less, then do not need to call again
      # Extract information about questionnaires on server
      qnrList_all <<- as.data.frame(qnrList$Questionnaires)

    } else {
      # If more than 40 questions, run query again to get the rest
      data2 <- GET(query, authenticate(user, password),
                  query = list(limit = 40, offset = 2))

      qnrList2 <- fromJSON(content(data2, as = "text"), flatten = TRUE)

      qnrList_all <<- bind_rows(qnrList_all,
                           as.data.frame(qnrList2$Questionnaires))
    }
    } else if (status_code(data) == 401) {   # login error
    message("Incorrect username or password. Check login credentials for API user")
      } else {
    #
    message("Encountered issue with status code ", status_code(data))
      }
}
