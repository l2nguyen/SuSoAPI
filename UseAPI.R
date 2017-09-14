# clear work space
rm(list=ls())

# load packages
library(httr)       # to send requests to API
library(jsonlite)   # to prettify JSON data
library(dplyr)      # to wrangle the data from the API

#----------- SERVER/TEMPLATE DETAILS ------------------#
# !NOTE: You will need to replace these with you server
# details before using this code

# server prefix (the name before mysurvey.solutions)
server <- "lena"
# template ID
template <- "42214963-2299-429a-9288-7a1bbcfadff7"
# Desired name of zip file
Zname <- "test_data"

#-------- GET LIST OF QUESTIONNAIRES IMPORTED IN A SERVER ------#
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
  else message("Encountered issue with status code ",status_code(data))
}

getQx(server)

#---------- FUNCTION TO EXPORT DATA ---------------#
# NOTE: This function exports data using the 
# Survey Solutions API in a zip file in the current working directory
# and then unzips it into the same directory
# The default export type is tabular and default data file name is "data"

getData <- function(server,
                 template,
                 version,
                 export_type="tabular",
                 user="APIuser",
                 password="Password123",
                 filename="data")
{
  # build base URL for API
  baseURL <- sprintf("%s/api/v1", 
                   server)
  
  exportURL <- sprintf("https://%s.mysurvey.solutions/export/%s/%s$%i/", 
                     baseURL, export_type, template, version)
  
  # post request to API
  action = "start"
  
  query = paste0(exportURL,action)
  
  data <- POST(query, authenticate(user, password))
  
  if (status_code(data)==401) {
    stop_for_status(test,"log into API using provided username and password")
  }
  
  # download data
  else if (status_code(data)==200) {
    action = ""
    query <- paste0(exportURL, action) 
  
    data2 <- GET(query, authenticate(user, password))
  
    # concatenate file name
    zip_name <- file.path(paste0(filename,"_", format(Sys.time(), "%d_%b_%Y"),".zip"))

    bin <- content(data2,"raw")
    # write content to the zip file
    writeBin(bin, zip_name) 
  
    unzip(zip_name,exdir=paste0(filename,"_",format(Sys.time(), "%d_%b_%Y")))
  } 
}

# export data
getData(server=server,template=template,version=2,export_type="stata", filename=Zname)
