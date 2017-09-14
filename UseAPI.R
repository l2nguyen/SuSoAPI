# clear work space
rm(list=ls())

# load packages
library(httr)
library(jsonlite)

#----------- TEMPLATE DETAILS ---------------------#
# server name
server <- "https://lena.mysurvey.solutions"
# template ID
template <- "42214963-2299-429a-9288-7a1bbcfadff7"
# Desired name of zip file
Zname <- "test_data"

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
  # build base URL
  baseURL <- sprintf("%s/api/v1", 
                   server)
  
  exportURL <- sprintf("%s/export/%s/%s$%i/", 
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
