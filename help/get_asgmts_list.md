## Gets the list of assignments

### Description
Gets the list of assignments for a certain version of a questionnaire. The user can find the questionnaire of interest using the template ID of the questionnaire or the name of the questionnaire. The user can also filter the list based on archived status and the interviewer/supervisor currently responsible for the assignment. The output can either be a data frame, tab delimited file or Excel file.

### Usage
```R
get_asgmts_list(template_id = NULL, qx_name = NULL, version = NULL,
                responsible = "", archived = FALSE,
                output = "df", output_path = NULL,
                server, user, password)
```

### Arguments
* **template_id** (*string*): Template ID of the questionnaire. Can specify either template_id or qx_name to find the questionnaire of interest. Do not specify both.
* **qx_name** (*string*): Name of the questionnaire. This is the name of the template on the server and not the template ID. Note that this is case sensitive. Can specify either template_id or qx_name to find the questionnaire of interest. Do not specify both. *To use this, you will need to have [get_qx function](help/get_qx.md) also.*
* **responsible** (*string*): Option to filter by the user responsible for the assignment. By default, it will find all assignments for the questionnaire regardless of who is responsible.
* **archived** (*boolean*): Option to search for archived assignments. If *TRUE*, the assignment list will only show archived assignments. By default, the list will only show active assignments.
* **version** (*integer*): Version of the questionnaire that you would like the assignments for.
* **output** (*string*): Desired output type for the list of assignments. Options are: "df" for data frame, "tab" for tab delimited file or "excel" for an Excel file.
* **output_path** (*string*): Name of the file that you would like to save the output as. This must be specified if the output type is tab or excel. Use forward slash (/) instead of backslash (\\).
* **server** (*string*): Prefix for the survey server. It is whatever comes before mysurvey.solutions: *[prefix]*.mysurvey.solutions.
* **user** (*string*): Username for the API user on the server.
* **password** (*string*): Password for the API user on the server.
