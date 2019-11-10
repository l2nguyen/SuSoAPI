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
# By default, this puts the questionnaire list onto the global

get_qx <- function(server, user, password, put_global=TRUE) {

  load_pkg <- function(x) {
    if (!require(x, character.only = TRUE)) {
      install.packages(x, repos = 'https://cloud.r-project.org/', dep = TRUE)
    }
    library(x, character.only = TRUE)
  }

  # require packages
  load_pkg("httr")
  load_pkg("jsonlite")
  load_pkg("dplyr")

  # build base URL for API
  API_URL <- sprintf("https://%s.mysurvey.solutions/api/v1",
                     server)

  # build query
  query <- paste0(API_URL, "/questionnaires")

  # Send GET request to API
  data <- httr::GET(query, authenticate(user, password),
                    query = list(limit = 40, offset = 1))

  # If response code is 200, request was succesffuly processed
  if (httr::status_code(data)==200) {

    # save the list of imported templates from the API as a data frame
    qnrList <- jsonlite::fromJSON(content(data, as = "text"), flatten = TRUE)
    qnrList_temp <- as.data.frame(qnrList$Questionnaires)

    if (qnrList$TotalCount <= 40) {
      # if 40 questionnaires or less, then do not need to call again
      # Extract information about questionnaires on server
      qnrList_all <- dplyr::arrange(qnrList_temp, Title, Version)
    } else {
      quest_more <- list(qnrList_temp)
      # If more than 40 questionnaires, run query again to get the rest
      nquery <- ceiling(qnrList$TotalCount/40)

      # send query for more questionnaires
      for(i in 2:nquery){
        data2 <- httr::GET(query, authenticate(user, password),
                     query = list(limit = 40, offset = i))

        qnrList_more <- jsonlite::fromJSON(content(data2, as = "text"),
                                           flatten = TRUE)
        questList_more <- as.data.frame(qnrList_more$Questionnaires)
        # append loop df to list
        quest_more[[i]] <- questList_more
      }
      qnrList_temp <- dplyr::bind_rows(quest_more)
      qnrList_all <- dplyr::arrange(qnrList_temp, Title, Version)
    }

    if (put_global==TRUE){
      # assign to global environment for access by other functions
      assign('qnrList_all', qnrList_all, envir = .GlobalEnv)
    } else {
      return(qnrList_all)
    }

    } else if (httr::status_code(data) == 401) {   # login error
    message("Incorrect username or password. Check login credentials for API user")
      } else {
    # Issue error message
    message("Encountered issue with status code ", status_code(data))
      }
}
