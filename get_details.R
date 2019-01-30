# =============================================================================
# Get the status of the generation of the export file
# =============================================================================
# Args:
# API_URL: URL for API endpoint for export
# user: API user ID
# password: password for API user
# attempt: number of times the details of the export has been called
#
# Returns into the global environment:
# A data frame that has all the details returned from the server
# about the status of the export

get_details <- function(export_URL,
                        user,
                        password) {

  load_pkg <- function(x) {
    if (!require(x, character.only = TRUE)) {
      install.packages(x, repos = 'https://cloud.r-project.org/', dep = TRUE)
    }
    library(x, character.only = TRUE)
  }

  # load packages
  load_pkg("httr")
  load_pkg("jsonlite")
  load_pkg("dplyr")
  load_pkg("lubridate")

  #-- GET EXPORT STATUS DETAILS --#

  # Make URL for details
  details_query <- paste0(export_URL, "/details")

  # Get status of export from server
  statusExport <- GET(details_query, authenticate(user, password))

  # Get start time of export
  request_time <- as.POSIXct(headers(statusExport)$date, format = "%a, %d %b %Y %H:%M:%S", tz = "GMT")

  # convert start time into UTC for standardization with server response time
  request_time <- with_tz(request_time, "UTC")

  # Convert server response in JSON to data frame
  export_details <- fromJSON(content(statusExport, as = "text"), flatten = TRUE)

    # add time of last request sent to data frame
  export_details$request_time <- request_time

  # Time of last update of status from server.
  # NOTE: This is not the same as the time the details query was sent
  export_details$LastUpdateDate <- ymd_hms(export_details$LastUpdateDate, tz = "UTC")

  assign('export_details', export_details, envir = .GlobalEnv)
}
