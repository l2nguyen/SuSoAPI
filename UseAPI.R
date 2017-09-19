# clear work space
rm(list=ls())

# load packages
library(httr)       # to send requests to API
library(jsonlite)   # to prettify JSON data

#------------------------------------------------------#
#----------- SERVER/TEMPLATE DETAILS ------------------#
#------------------------------------------------------#
# !NOTE: These are the input data for the function to export data.
# You will need to replace these with you server
# and questionnaire details before running

# cloud server prefix (the name before mysurvey.solutions)
# NOTE: functions currently use the prefix of the cloud server
prefix <- "nship2017" #<--- Change to the prefix of your cloud server

# questionnaire name
Quest <- "Health Care Provider Interviews (HF7)"  #<--- Change to the desired template
# version number
vers <- 2
# export data type
type <- "stata"

# Put the user ID and password for the API user on your server
userId <- "APIuser"   #<--- Change to the user ID for the API user on your server
key <- "Password123"  #<--- Change to the password for the API user

# Desired directory to download data into
directory <- "C:\Downloads\"

#-------------------------------------------------------------------#
#-------- GET THE LIST OF QUESTIONNAIRES IMPORTED IN A SERVER ------#
#-------------------------------------------------------------------#
# NOTE: This will save the information from the server as a data frame

getQx <- function(server,
                  user="APIuser",
                  password="Password123")
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

# Get the list of all questionnaires on the server
getQx(server = prefix,
      user = userId,
      password = key)


#-------- GET THE TEMPLATE ID TO THE PROVIDED QUESTIONNAIRE NAME --------#

getQxId <- function(server, 
                    Qxname="",
                    user="APIuser",
                    password="Password123")
{
  # Stop and give an error if no questionnaire name provided
  if (Qxname=="") {
    stop("Please include the name of the questionnaire in the function.")
  } 
  else {
    #Get data about questionnaires on server
    getQx(server,user,password)
    # return ID associated with the questionnaire name
    return(quests$QuestionnaireId[quests$Title==Qxname])
  }
}

# get template ID using the name of the questionnaire
getQxId(server = prefix,
        Qxname = "Household Roster",
        user = userId,
        password = key)

#--------------------------------------------------------#
#-------------- FUNCTION TO EXPORT DATA -----------------#
#--------------------------------------------------------#

# NOTE: This function exports data using the 
# Survey Solutions API in a zip file into a selected directory
# and then unzips it into the same directory
# The default export type is tabular 

getData <- function(server,  # server prefix
                    user="APIuser",  # API user ID
                    password="Password123",  # password
                    qx_name,  # Name of questionnaire (not template ID)
                    version=1,  # version number
                    export_type="tabular", # export type
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
  
  if (result==401) {   # login error
    stop_for_status(result,
                    "log into API using provided username and password. Check log in credentials for API user")
  }
  else if (result==400 | result==404) {
    stop_for_status(result, 
                    "to find questionnaire. Check template ID and version number.")
  }
  else if (result==200) {   #if request was posted sucessfully
    # Display message that the exporting process is starting
    message("Requesting data sets to be compiled on server...")
  }
  
  # Wait 60 seconds for export to be made
  message("Waiting for export files to be generated...")
  Sys.sleep(30)
  
  #----- CHECK STATUS OF EXPORT ------#
  action = "details"
  query = paste0(exportURL,action)

  details_data <- GET(query, authenticate(user, password))
  details <- fromJSON(content(details_data,as="text"), flatten=TRUE)
  
  # If server is still working on generating export data, wait and then check status again
  while (details$ExportStatus=="Queued" | details$ExportStatus=="Running") {
    # Wait 30 seconds
    Sys.sleep(30)
    
    # Check details again
    action = "details"
    query = paste0(exportURL,action)
    
    details_data <- GET(query, authenticate(user, password))
    details <- fromJSON(content(details_data,as="text"), flatten=TRUE)
  }
  
  # If export is file is finished being produced, download data file
  if (details$ExportStatus=="Finished") {
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
  
    unzip(zip_name,exdir=zip_path)
    message("Data files successfully downloaded into folder: ", zip_path)

  } else if (details$ExportStatus=="FinishedWithErrors") {
    # If error generating export file, try to download data again from beginning
    getData(server, user, password, qx_name, version, export_type, folder)
  }
  
}

# export data
getData(server = prefix,
        user= userId,
        password = key,
        qx_name = Quest,
        version = vers,
        export_type = type,
        folder = directory)
