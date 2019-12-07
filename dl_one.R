#---------------------------------------------#
#------- EXPORT DATA FROM ONE TEMPLATE -------#
#---------------------------------------------#
# For how to use, see:
# https://github.com/l2nguyen/SuSoAPI/blob/master/help/dl_one.md

dl_one <- function(
                    qx_name,  # Name of questionnaire (not template ID)
                    version = 1,  # version number
                    export_type = "tabular", # export type
                    folder,
                    unzip = TRUE, #option to unzip file after download
                    server,  # server prefix
                    user = "APIuser",  # API user ID
                    password = "Password123",  # password,
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
    require(x, character.only = TRUE)
  }

  load_pkg('stringr')
  load_pkg('jsonlite')
  load_pkg('httr')
  load_pkg('lubridate')
  load_pkg('here')

  source(here::here("get_details.R"))
  source(here::here("get_qx.R"))

  # -------------------------------------------------------------
  # Get list of questionnaires from server
  # -------------------------------------------------------------

  # build base URL for API
  server <- tolower(str_trim(server))

  api_URL <- sprintf("https://%s.mysurvey.solutions/api/v1",
                     server)

  # check if list of questionnaire already exists
  if (!exists("qnrList_all")) {
    get_qx(server, user = user, password = password)
  }

  # check version number is numeric
  if (!is.numeric(version)) {
    if (is.na(as.numeric(version))) {
      stop("Version number ", version, " is not numeric.")
    } else version <- as.numeric(version)
  }

  # trim white space before
  qx_name <- str_trim(qx_name)

  # Get ID of template to get export URL
  qx_match <- filter(qnrList_all, Title == qx_name, Version == version)

  if (nrow(qx_match) == 1) {
    qx_id <- qx_match$QuestionnaireIdentity
    # questionnaire variable for naming zip file later
    qx_var <- qx_match$Variable
  } else {
    stop("Template does not exist on server. Check questionnaire name and version number.")
  }

  # -----------------------------------------------------------------------------
  # Request export files to be created
  # -----------------------------------------------------------------------------

  export_URL <- sprintf("%s/export/%s/%s",
                        api_URL, export_type, qx_id)

  # post request to API
  start_query <- paste0(export_URL, "/start")

  startExport <- POST(start_query, authenticate(user, password))

  # Get start time of export
  if (is.na(headers(startExport)$date)) {
    # take the date in case the response header is missing
    start_time <- as.POSIXct(startExport$date,
                            format = "%Y-%m-%d %H:%M:%S", tz = "GMT")
  } else {
    start_time <- as.POSIXct(headers(startExport)$date,
                            format = "%a, %d %b %Y %H:%M:%S", tz = "GMT")
  }

  # convert start time into UTC for standardization with server response time
  start_time <- with_tz(start_time, "UTC")

  # -----------------------------------------------------------------------------
  # Obtain status of export file creation
  # -----------------------------------------------------------------------------

  if (status_code(startExport) == 200) {   #if request was posted sucessfully
    # Display message that the exporting process is starting
    message("Requesting data for ",
            qx_name, " v", version,
            " to be compiled on server.")

    # wait 5 second between start request and status request
    Sys.sleep(5)

    #-- Get details of export status --#
    export_details <- get_details(export_URL, user, password)

  }	else if (status_code(startExport) == 400 | status_code(startExport) == 404) {
    stop_for_status("Check questionnaire name and version number.")
  }

  # alert user that export has started
  message("Waiting for export files to be generated...")

  # -----------------------------------------------------------------------------
  # React to status
  # -----------------------------------------------------------------------------
  # Note: This will try to download the data as many times as the user specified,
  # it is 10 by default

  requestCounter <- 1

  # If server is still working on generating export data, wait and then check status again
  while (export_details$ExportStatus %in%
         c("NotStarted", "Queued", "Running","Compressing")
         & requestCounter <= tries) {
    # Wait 10 seconds
    Sys.sleep(10)

    # Check details again
    export_details <- get_details(export_URL, user, password)

    # get time of last update
    last_update <- export_details$LastUpdateDate

    # for display purposes
    message(paste0("Request number: ", requestCounter))
    message(paste0("Status: ", export_details$ExportStatus))

    if (export_details$ExportStatus == "Running") {
      message(paste0("Percent: ",
                     export_details$RunningProcess['ProgressInPercents'], '%'))
    }

    # If running or queued, keep waiting and check status again
    if (export_details$ExportStatus %in% c("Queued", "Running", "Compressing")) {

      # wait before making another request,
      # where time is a function of the number of requests
      Sys.sleep(10 * requestCounter)

      requestCounter <- requestCounter + 1
    } else if (export_details$ExportStatus == "NotStarted") {
      # check if exported file has already finished and export file now exists
      # NOTE: Tabular data files generate so quickly that the server has reverted
      # back to "Not Started" status by the time we check for details.
      if (export_details$HasExportedFile == TRUE) {
        # if last update is after request, then file is ready to download
        if (is.null(last_update) == TRUE | last_update >= start_time) {

          # Change export status to finished because it is finished
          export_details$ExportStatus <- "Finished"

          # exit while loop, and download file
          break
        } else if (last_update < start_time) {
          # start export again if query did not go through for some reason
          startExport <- POST(start_query, authenticate(user, password))

          # wait before making another request,
          # where time is a function of the number of requests
          Sys.sleep(10 * requestCounter)
          # increment the counter of requests
          requestCounter <- requestCounter + 1
        }
      } else {
        # wait until making another request
        Sys.sleep(10 * requestCounter)

        # increment number of request
        requestCounter <- requestCounter + 1
      }
    }
  }

  # If export is file is finished being produced, download data file
  if (export_details$ExportStatus == "Finished") {
    # Set folder to directory specified by user
    # concatenate file name - the name matches the name of a manual download
    zip_path <- paste0(folder,"/",
                       qx_var, "_",
                       version, "_",
                       str_to_upper(export_type), "_",
                       "All")

    # name of zip file
    zip_name <- paste0(zip_path, ".zip")

    # Query to download data
    downloadData <- GET(
      export_URL,
      accept_json(),
      authenticate(user, password),
      # write to disk that handles large files
      write_disk(zip_name, overwrite = TRUE),
      # show progress of download
      progress(),
      config(                                 # use curl options to:
        followlocation = 1L,                      # follow redirects
        unrestricted_auth = 0L                    # but not pass auth to redirects
        )
    )

    # check status code of query
    if (status_code(downloadData) == 200) {
      message("Sucessfully exported ", qx_name, " version ", version)

      # unzip
      if (unzip == TRUE) {
        unzip(zipfile=zip_name, exdir = zip_path, unzip = getOption("unzip"))
      }
      message("Data files successfully downloaded into folder: ", "\n", zip_path)
    } else {
      message(paste0("Problem downloading data. Server status code: ",
                     status_code(downloadData)))
    }
  }

  # if finished with errors - try again
  #if (details$ExportStatus == "FinishedWithErrors") {
     # add something for it to try again
  # }
}
