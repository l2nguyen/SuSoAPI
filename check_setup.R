# =============================================================================
# Function to check set up before trying to download data
# =============================================================================
# Args:
# server: server variable is the URL for the API
# user: API user ID
# password: password for API user

check_setup <- function(server, api_user, password) {
  message("Checking set up. Please wait...")

	# check that running recent version of R
	majorVersion <- type.convert(R.Version()$major)
	minorVersion <- type.convert(R.Version()$minor)
	if ((majorVersion > 3 | (majorVersion == 3 & minorVersion >= 4.3)) == FALSE) {
		browseURL("https://cran.r-project.org/")
		stop("Update your version of R. Either download from CRAN or use the installr package.")
	}

	# reinitialize error log
	failedExportFile <- "dsets that failed to download.csv"
	if ( file.exists(failedExportFile) ) {
		file.remove(failedExportFile)
	}

	# confirm that expected folders exist
	if (!dir.exists(dataDir)) {
		stop("Data folder does not exist in the expected location: ", dataDir)
	}

	message("Checking login credentials. Please wait...")

	# confirm that server exists
	serverCheck <- try(http_error(server), silent = TRUE)
	if (class(serverCheck) == "try-error") {
		stop("The following server does not exist. Please correct this program's server parameter",
		     "\n", server)
	}

	# check that server, login, password, and data type are non-missing
	for (x in c("server", "login", "password", "dataType")) {
	  if (!is.character(get(x))) {
	    stop("Check that the parameters in the data are the correct data type.")
	  }
	  if (nchar(get(x)) == 0) {
		stop(paste("The following parameter is not specified in the program:", x))
	  }
	}

	# check that logins are valid for server
	loginsToCheck <- paste0(server, "questionnaires")
	loginsOK <- GET(loginsToCheck, authenticate(api_user, password))

	if (status_code(loginsOK) == 401) {
		stop("The login and/or password provided are incorrect.", "\n",
			"Login : ", api_user, "\n",
			"Password : ", password, "\n"
		)
	}

	# Check if it is a valid data type
	if ((tolower(dataType) %in% c("tabular","stata","spss", "binary", "paradata")) == FALSE) {
		stop("Data type has to be one of the following: Tablular, STATA, SPSS, Binary, paradata")
	}

	message("Check completed.")
}
