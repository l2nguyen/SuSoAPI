## Downloads data for all versions of a questionnaire

### Description
Exports data from all versions of a specified questionnaire

### Usage
```R
dl_allVers(qx_name, ignore.case = TRUE, 
           export_type = "tabular", folder, unzip = TRUE,
           server, user = "APIuser", password = "Password123", tries = 10)
```

### Arguments
* **qx_name** (*string*): Name of the template to download. This is the name of the template on the server and not the template ID. Note that this is case sensitive.
* **ignore.case** (*boolean*): Whether the match for pattern and exclusionary terms should be case sensistive. It is set to *TRUE* by default so the match is not case sensitive.
* **export_type** (*string*): The type of data to export. Options are tabular, stata, spss, binary, paradata. Default is tabular.
* **folder** (*string*): The directory to export the data into. Must be a string. Use forward slash (/) instead of backslash (\\).
* **unzip** (*boolean*):  Option to unzip the downloaded zip file into the same directory. By default, it will unzip. Set this parameter to *FALSE* if you would like to not unzip the exported data after download.
* **server** (*string*): Prefix for the survey server. It is whatever comes before mysurvey.solutions: *[prefix]*.mysurvey.solutions.
* **user** (*string*): Username for the API user on the server.
* **password** (*string*): Password for the API user on the server.
* **tries** (*numeric*): Number of times to try getting an export before moving on to next one. Default is 10 times. If you are expecting the dataset on your servers to take a long time to export, increase the number of tries.


### Examples
I have a survey that uses the cloud server **lf2018.mysurvey.solutions** for data collection. I want to use the API to export the data for *all the versions* of my questionnaire called **LF Survey 2018**. I want the data in **Stata format** and I would like the data to be **unzipped after download**. I want to download the data into the folder: **C:/User/LF_Survey/Data/"**. On my server, I made an API user with the login: **APIuser2018** and password: **SafePassword123**. To use **dl_allVers** to download the data for that questionnaire, after loading the **dl_allVers** function into the workspace, I would run the following code:

```R
dl_allVers(qx_name = "LF Survey 2018", ignore.case = TRUE, export_type = "stata", 
      folder = "C:/User/LF_Survey/Data/", unzip = TRUE, 
      server = "lf2018", user = "APIuser2018", password = "SafePassword123")
```

Since I set the ignore.case parameter to be TRUE for the function, the questionnaire name is not case sensitive so I do not have to capitalize the questionnaire name exactly as it appears on the server. The following code will also work:
```R
dl_allVers(qx_name = "LF SURVEY 2018", ignore.case = TRUE, export_type = "stata", 
      folder = "C:/User/LF_Survey/Data/", unzip = TRUE, 
      server = "lf2018", user = "APIuser2018", password = "SafePassword123")
```

```R
dl_allVers(qx_name = "lf survey 2018", ignore.case = TRUE, export_type = "stata", 
      folder = "C:/User/LF_Survey/Data/", unzip = TRUE, 
      server = "lf2018", user = "APIuser2018", password = "SafePassword123")
```
