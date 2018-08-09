## Downloads data for all questionnaires with similar names

### Description
Exports data from all questionnaires that match a provided pattern. Function uses [str_detect](https://www.rdocumentation.org/packages/stringr/versions/1.3.1/topics/str_detect) to match the pattern so a regular expression pattern can be used. Additionally, there is the option to exclude questionnaires that have certain words in them (ie training, practice). This function uses the [dl_one function](dl_one.md) so it has similar parameters. 

### Usage
```R
dl_similar(pattern, exclude = NULL, ignore.case = TRUE, 
      export_type = "tabular", folder, unzip = TRUE, 
      server, user = "APIuser", password = "Password123")
```

### Arguments
* **pattern** (*string*): Pattern to match in the name of questionnaires to download. Can use regular expression for this.
* **exclude** (*string* or list of strings): Questionnaire names with words in this exclude list will not be downloaded.
* **ignore.case** (*boolean*): Whether the match for pattern and exclusionary terms should be case sensistive. It is set to *TRUE* by default so the match is not case sensitive.
* **export_type** (*string*): The type of data to export. Options are tabular, stata, spss, binary, paradata. Default is tabular.
* **folder** (*string*): The directory to export the data into. Must be a string. Use forward slash (/) instead of backslash (\\).
* **unzip** (*boolean*):  Option to unzip the downloaded zip file into the same directory. By default, it will unzip. Set this parameter to *FALSE* if you would like to not unzip the exported data after download.
* **server** (*string*): Prefix for the survey server. It is whatever comes before mysurvey.solutions: *[prefix]*.mysurvey.solutions.
* **user** (*string*): Username for the API user on the server.
* **password** (*string*): Password for the API user on the server.


### Examples

