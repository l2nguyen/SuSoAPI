# clear work space
rm(list=ls())

# load packages
library(httr)       # to send requests to API
library(jsonlite)   # to prettify JSON data

#-------------------------------------------------------------------#
#-------- GET THE LIST OF QUESTIONNAIRES IMPORTED IN A SERVER ------#
#-------------------------------------------------------------------#
# NOTE: This will save the information from the server as a data frame

# Args: 
# server: server prefix
# user: API user ID, default is API user
# password: password for API user, default is Password 123
#
# Returns:
# A data frame that has all the information about the imported
# questionnaires on the server. This is a prettified version of the JSON response.

getQx <- function(server,
                  user = "APIuser",
                  password = "Password123")
{
  # build base URL for API
  baseURL <- sprintf("https://%s.mysurvey.solutions/api/v1/", 
                     server)
  
  # build quetry
  query <- paste0(baseURL, "questionnaires")
  
  # Send GET request to API
  data<- GET(query, authenticate(user, password))
  
  # If response code is 200, request was succesffuly processed
  if (status_code(data)==200) {
    
    # save the list of imported templates from the API as a data frame
    fromAPI <- fromJSON(content(data,as="text"), flatten=TRUE)
    
    # Extract information about questionnaires on server
    quests <<- as.data.frame(fromAPI$Questionnaires)
  }
  # if request was not successful, print error message
  else message("Encountered issue with status code ", status_code(data))
}

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

getQxId <- function(server, 
                    Qxname = "",
                    user = "APIuser",
                    password = "Password123")
{
  # Stop and give an error if no questionnaire name provided
  if (Qxname=="") {
    stop("Please provide the name of the questionnaire.")
  } 
  else {
    #Get data about questionnaires on server
    getQx(server,user,password)
    # return ID associated with the questionnaire name
    return(unique(quests$QuestionnaireId[quests$Title==Qxname]))
  }
}

#--------------------------------------------#
#-------------- CHECK STATUS ----------------#
#--------------------------------------------#
# NOTE: The following is auxiliary functions to be 
# used in the data export function below.
# This is used to check the status of the
# export
getDetails <- function(exportURL,
                       user = "APIUser",
                       password = "Password123")
{
  #----- CHECK STATUS OF EXPORT ------#
  action = "details"
  query = paste0(exportURL,action)
  
  details_data <- GET(query, authenticate(user, password))
  details <- fromJSON(content(details_data,as="text"), flatten=TRUE)
}

#--------------------------------------------#
#-------------- EXPORT DATA -----------------#
#--------------------------------------------#
# Args: 
# server: server prefix
# user: API user ID, default is API user
# password: password for API user, default is Password 123
# qx_name: Name of the questionnaire of interest
# version: version number of the data you would like to export
# export type: the data type that you would like to export
# options are tabular, stata, spss, binary, paradata
# folder: the directory you would like to export the data into. Use '\\' instead of '\'
#
# Returns:
# The exported data will be downloaded into the specified directory
# It also unzips the downloaded file into the same directory

getData <- function(server,  # server prefix
                    user = "APIuser",  # API user ID
                    password = "Password123",  # password
                    qx_name,  # Name of questionnaire (not template ID)
                    version = 1,  # version number
                    export_type ="tabular", # export type
                    folder)
{
  
  # build base URL for API
  baseURL <- sprintf("https://%s.mysurvey.solutions/api/v1", 
                     server)
  
  # Get ID of template to get export URL
  template <- getQxId(server, qx_name, user, password)
  
  exportURL <- sprintf("%s/export/%s/%s$%i/", 
                       baseURL, export_type, template, version)
 
  #---- START EXPORT ------# 
  # post request to API
  action = "start"
  
  query = paste0(exportURL,action)
  data <- POST(query, authenticate(user, password))
  
  result <- status_code(data)
  
  # error handling
  if (result == 401) {   # login error
    stop_for_status(result,
                    "log into API using provided username and password. Check log in credentials for API user")
  }
  else if (result == 400 | result == 404) {
    stop_for_status(result, 
                    "to find questionnaire. Check template name and version number.")
  }
  else if (result == 200) {   #if request was posted sucessfully
    # Display message that the exporting process is starting
    message("Requesting data sets to be compiled on server...")
  }
  
  # Wait 30 seconds for export to be made
  message("Waiting for export files to be generated...")
  Sys.sleep(30)
  
  #----- CHECK STATUS OF EXPORT ------#
  action = "details"
  query = paste0(exportURL,action)
  
  details_data <- GET(query, authenticate(user, password))
  details <- fromJSON(content(details_data,as="text"), flatten=TRUE)
  
  # If server is still working on generating export data, wait and then check status again
  while (details$ExportStatus == "Queued" | details$ExportStatus == "Running") {
    # Wait 30 seconds
    Sys.sleep(30)
    
    # Check details again
    action = "details"
    query = paste0(exportURL,action)
    
    details_data <- GET(query, authenticate(user, password))
    details <- fromJSON(content(details_data,as="text"), flatten=TRUE)
  }
  
  # If export is file is finished being produced, download data file
  if (details$ExportStatus == "Finished") {
    action = ""
    query <- paste0(exportURL, action) 
  
    data2 <- GET(query, authenticate(user, password))
    
    # Let user choose directory
    #folder<- choose.dir(getwd(), caption="Choose the folder to download the data to...")
    
    # Set folder to directory specified by user
    
    # concatenate file name
    zip_path <- paste0(folder,"\\", 
                       qx_name, "_", 
                       "v", version, "_", 
                       export_type, "_", 
                       format(Sys.time(), "%d_%b_%Y"))
    
    # name of zip file
    zip_name <- paste0(zip_path,".zip")
    
    bin <- content(data2,"raw")
    # write content to the zip file
    writeBin(bin, zip_name)
    message("Sucessfully exported ", qx_name, " version ", version)
  
    unzip(zip_name,exdir = zip_path)
    message("Data files successfully downloaded into folder: ", "\n", zip_path)

  } else if (details$ExportStatus == "FinishedWithErrors") {
    # If error generating export file, try to download data again from beginning
    getData(server, user, password, qx_name, version, export_type, folder)
  }
  
}


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

getAllVers <- function(server,
                       user = "APIuser",  # API user ID
                       password = "Password123",  # password
                       qx_name,  # Name of questionnaire (not template ID)
                       export_type ="tabular", # export type
                       folder   # directory for data download
                       )
{
  # First, get questionnaire information from server
  getQx(server,user,password)
  
  # get all versions of the questionnaire on the server
  allVers <- quests$Version[quests$Title==Quest]
  
  # Export data for each version if more than one version
  for (i in allVers) {
          getData(
          server = prefix,
          user= userId,
          password = key,
          qx_name = Quest,
          version = i,
          export_type = type,
          folder = directory
          )
  }
}

#------------------------------------------------------#
#----------- SERVER/TEMPLATE DETAILS ------------------#
#------------------------------------------------------#
# !NOTE: These are the input data for the function to export data.
# You will need to replace these with you server
# and questionnaire details before running

# cloud server prefix (the name before mysurvey.solutions)
# NOTE: functions currently use the prefix of the cloud server
prefix <- "lena" #<--- Change to the prefix of your cloud server

# questionnaire name
Quest <- "Tanzania National Panel Survey Wave 5 (DRAFT)"  #<--- Change to the desired questionnaire
# version number
vers <- 13
# export data type
type <- "stata"

# Put the user ID and password for the API user on your server
userId <- "APIuser"   #<--- Change to the user ID for the API user on your server
key <- "Password123"  #<--- Change to the password for the API user

# Desired directory to download data into
directory <- "C:\\Users\\wb415892\\Downloads\\" #<--- change to your directory. Use \\ instead of \


#------------------- TEST THE FUNCTIONS ---------------------#

# Get the list of all questionnaires on the server
getQx(server = prefix,
      user = userId,
      password = key)

# get template ID using the name of the questionnaire
getQxId(server = prefix,
        Qxname = "Household Roster",
        user = userId,
        password = key)

# export data
getData(server = prefix,
        user= userId,
        password = key,
        qx_name = Quest,
        version = vers,
        export_type = type,
        folder = directory)

# Export all versions of a questionnaire
getAllVers(server = prefix,
           user= userId,
           password = key,
           qx_name = Quest,
           export_type = type,
           folder = directory)
