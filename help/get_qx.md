## Export data from one template

### Description
Returns a data frame called *qnrList_all* with information about all the questionnaires that are currently imported on the specified server. The *qnrList_all* data frame will have the following columns:
* **QuestionnaireId**: Unique ID for that template. Different versions of the same template should have the same QuestionnaireId.
* **Version**: Version number of the questionnaire
* **Title**: Name of the questionnaire
* **LastEntryDate**: Time the questionnaire was imported into the server in UTC.

**NOTE**: *qnrList_all* is currently being assigned to the global environment so that data can be accessed when get_qx function is nested in other functions. This might cause issues if you are trying to use the *dl_one* function across different servers.

### Usage
```R
get_qx(server, user, password)
```

### Arguments
* **server** (*string*): Prefix for the survey server. It is whatever comes before mysurvey.solutions: *[prefix]*.mysurvey.solutions.
* **user** (*string*): Username for the API user on the server.
* **password** (*string*): Password for the API user on the server.

### Examples
I would like to get all the imported questionnaires on the server **lf2018.mysurvey.solutions** for data collection. On my server, I made an API user with the login: **APIuser2018** and password: **SafePassword123**. To get all the questionnaire

```R
get_qx(server = "lf2018", user = "APIuser2018", password = "SafePassword123")
```
