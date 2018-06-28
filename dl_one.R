#---------------------------------------------#
#------- EXPORT DATA FROM ONE TEMPLATE -------#
#---------------------------------------------#
# Args: 
# server: server prefix
# user: API user ID, default is APIuser
# password: password for API user, default is Password123
# qx_name: Name of the questionnaire to download
# version: version number of the data you would like to export
# export type: the data type that you would like to export
# options are tabular, stata, spss, binary, paradata
# folder: the directory you would like to export the data into. Use '\\' instead of '\'
#
# Returns:
# The exported data will be downloaded into the specified directory
# It also unzips the downloaded file into the same directory

dl_one <- function(server,  # server prefix
                    user = "APIuser",  # API user ID
                    password = "Password123",  # password
                    qx_name,  # Name of questionnaire (not template ID)
                    version = 1,  # version number
                    export_type ="tabular", # export type
                    folder)
{
  source("check_setup.R")
  source("get_details.R")
  source("get_qx.R")
  source("get_qx_id.R")
  source("serverDetails.R")
  
  require(stringr)
  require(jsonlite)
  require(httr)
  require(lubridate)
  
  # build base URL for API
  api_URL <- sprintf("https://%s.mysurvey.solutions/api/v1", 
                     server)
  
  # trim white space before
  qx_name <- str_trim(qx_name)
  
  # Get ID of template to get export URL
  template <- get_qx_id(server, qx_name, user, password)
  
  export_URL <- sprintf("%s/export/%s/%s$%i/", 
                        api_URL, export_type, template, version)
  
  # -----------------------------------------------------------------------------
  # Request export files to be created
  # -----------------------------------------------------------------------------
  # post request to API
  start_query <- paste0(export_URL, "start")
  
  startExport <- POST(start_query, authenticate(user, password))
  
  # Get start time of export
  start_time <- as.POSIXct(headers(startExport)$date, format = "%a, %d %b %Y %H:%M:%S", tz = "GMT")
  
  # convert start time into UTC for standardization with server response time
  start_time <- with_tz(start_time, "UTC")
  
  # -----------------------------------------------------------------------------
  # Obtain status of export file creation
  # -----------------------------------------------------------------------------
  
  if (status_code(startExport) == 200) {   #if request was posted sucessfully
    # Display message that the exporting process is starting
    message("Requesting data sets to be compiled on server...")
    
    # wait 1 second between start request and status request
    Sys.sleep(1)
    
    #-- Get details of export status --#
    get_details(export_URL, user, password)
    
  }	else if (status_code(startExport) == 400 | status_code(startExport) == 404) {
    stop_for_status(start_result,
                    "to find questionnaire. Check template name and version number.")
  }
  
  # Wait 10 seconds for export to be made
  message("Waiting for export files to be generated...")
  
  # -----------------------------------------------------------------------------
  # React to status
  # -----------------------------------------------------------------------------
  # Note: This will try to download the data 5 times
  
  requestCounter <- 1
  
  # If server is still working on generating export data, wait and then check status again
  while (export_details$ExportStatus %in% c("NotStarted", "Queued", "Running") 
         & requestCounter <= 5) {
    # Wait 10 seconds
    Sys.sleep(10)
  
    
    # Check details again
    get_details(export_URL, user, password)
    
    # for debugging purposes
    message(paste0("Request number: ", requestCounter))
    message(paste0("Status: ", export_details$ExportStatus))
    
    last_update <- as.POSIXct(export_details$LastUpdateDate, 
                              format = "%a, %d %b %Y %H:%M:%S", tz = "GMT")
  

    # If running or queued, keep waiting and check status again
    if (export_details$ExportStatus %in% c("Queued","Running")) {
      
      # wait before making another request,
      # where time is a function of the number of requests
      Sys.sleep(5 * requestcounter)
    }
    
    # if creation of files not started
    if (export_details$ExportStatus == "NotStarted" & export_details$HasExportedFile == TRUE) {
      
      # check if exported file has already finished and export file now exists
      # NOTE: Tabular data files generate so quickly that the server has reverted
      # back to "Not Started" status by the time we check for details.
      
      # if last update is after request, then file is ready to download
      if (is.null(last_update) == TRUE | last_update >= start_time) {
        
        # Change export status to finished because it is finished
        export_details$ExportStatus <- "Finished"
        
        # exit while loop, and download file
        break
        
      } else if (last_update < startReqTime) {
        # start export again if query did not go through for some reason
        startExport <- POST(start_query, authenticate(user, password))
        
        # wait before making another request,
        # where time is a function of the number of requests
        Sys.sleep(5 * requestCounter)
        # increment the counter of requests
        requestCounter <- requestCounter + 1
      }
    }
  }
  
  # If export is file is finished being produced, download data file
  if (export_details$ExportStatus == "Finished") {
    # Set folder to directory specified by user
    # concatenate file name
    zip_path <- paste0(folder,"\\", 
                       qx_name, "_", 
                       "v", version, "_", 
                       export_type)
    
    # name of zip file
    zip_name <- paste0(zip_path,".zip")
    
    # Query to download data
    downloadData <- GET(
      export_URL,
      authenticate(user, password)
    )
    
    if (status_code(downloadData) == 200) {
      
      bin <- content(downloadData,"raw")
      # write content to the zip file
      writeBin(bin, zip_name)
      message("Sucessfully exported ", qx_name, " version ", version)
      
      unzip(zip_name,exdir = zip_path)
      message("Data files successfully downloaded into folder: ", "\n", zip_path)
    } else {
      failureDesc	= paste0("Problem dowloading. Server status code: ", status_code(downloadData))
    }
    
  } 
  
  # if finished with errors - try again
  #if (details$ExportStatus == "FinishedWithErrors") {
     # add something for it to try again
  # }
}
