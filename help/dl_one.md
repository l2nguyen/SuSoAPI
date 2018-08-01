## Export data from one template

### Description
Exports data from a version of the specified questionnaire using the Survey Solutions API. The function check the status of the download 5 times and wait progressively longer every time it checks for the export to finish.

### Usage
```R
dl_one(qx_name, version = 1, export_type = "tabular", folder, unzip = TRUE, 
	server, user = "APIuser", password = "Password123")
```

### Arguments
* **qx_name** (*string*): Name of the template to download. This is the name of the template on the server and not the template ID.
* **version** (*integer*): Version number of the template to export data for. Default value is 1.
* **export_type** (*string*): The type of data to export. Options are tabular, stata, spss, binary, paradata. Default is tabular.
* **folder** (*string*): The directory to export the data into. Must be a string. Use forward slash (/) instead of backslash (\\).
* **unzip** (*boolean*):  Option to unzip the export zip file after download into the same directory. It will unzip by default.
* **server** (*string*): Prefix for the survey server. It is whatever comes before mysurvey.solutions: *[prefix]*.mysurvey.solutions.
* **user** (*string*): Username for the API user on the server.
* **password** (*string*): Password for the API user on the server.


### Example
