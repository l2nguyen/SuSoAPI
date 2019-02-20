## Export data from one template

### Description
Exports data from a version of the specified questionnaire using the Survey Solutions API. The function check the status of the download 5 times and wait progressively longer every time it checks for the export to finish.

### Usage
```R
dl_one(qx_name, version = 1, export_type = "tabular", folder, unzip = TRUE, 
	server, user = "APIuser", password = "Password123", tries = 10)
```

### Arguments
* **qx_name** (*string*): Name of the template to download. This is the name of the template on the server and not the template ID. Note that this is case sensitive.
* **version** (*integer*): Version number of the template to export data for. Default value is 1.
* **export_type** (*string*): The type of data to export. Options are tabular, stata, spss, binary, paradata. Default is tabular.
* **folder** (*string*): The directory to export the data into. Must be a string. Use forward slash (/) instead of backslash (\\).
* **unzip** (*boolean*):  Option to unzip the downloaded zip file into the same directory. By default, it will unzip. Set this parameter to *FALSE* if you would like to not unzip the exported data after download.
* **server** (*string*): Prefix for the survey server. It is whatever comes before mysurvey.solutions: *[prefix]*.mysurvey.solutions.
* **user** (*string*): Username for the API user on the server.
* **password** (*string*): Password for the API user on the server.
* **tries** (*numeric*): Number of times to try getting an export before moving on to next one. Default is 10 times. If you are expecting the dataset on your servers to take a long time to export, increase the number of tries.

### Examples
I have a survey that uses the cloud server **lf2018.mysurvey.solutions** for data collection. I want to use the API to export the data for **version 3** of a questionnaire called **LF Survey 2018**. I want the data in **Stata format** and I would like the data to be **unzipped after download**. I want to download the data into the folder: **C:/User/LF_Survey/Data/"**. On my server, I made an API user with the login: **APIuser2018** and password: **SafePassword123**. To use **dl_one** to download the data for that questionnaire, after loading the **dl_one** into the workspace, I would run the following code:

```R
dl_one(qx_name = "LF Survey 2018", version = 3, export_type = "stata", 
      folder = "C:/User/LF_Survey/Data/", unzip = TRUE, 
      server = "lf2018", user = "APIuser2018", password = "SafePassword123")
```
