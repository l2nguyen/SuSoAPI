## Downloads data for all versions of a questionnaire

### Description
Exports data from all versions of a specified questionnaire. It is important to note that this function exports all versions on the server of questionnaires that share the same template Id/questionnaire variable and **not the same questionnaire name**. Users can use the keep/drop parameters to get data for the versions they are interested in exporting.

### Usage
```R
dl_allVers(qx_name, keep = NULL, drop = NULL,
           export_type = "tabular", folder, unzip = TRUE,
           server, user = "APIuser", password = "Password123", tries = 10)
```

### Arguments
* **qx_name** (*string*): Name of the template to download. This is the name of the template on the server and not the template ID. Note that this is case sensitive.
* **keep** (*integer* or vector of *integers*): Versions in this list will be be exported. This is useful if you would like to keep only a subset of all the versions.  Users can only specify versions to keep or drop but cannot specify both keep and drop as parameters. By default, all versions are kept.
* **drop** (*integer* or vector of *integers*): Versions in this list will not be exported. This is useful if you would like to drop a subset of all the versions. Users can only specify versions to keep or drop but cannot specify both keep and drop as parameters. By default, no versions are dropped.
* **export_type** (*string*): The type of data to export. Options are tabular, stata, spss, binary, paradata. Default is tabular.
* **folder** (*string*): The directory to export the data into. Must be a string. Use forward slash (/) instead of backslash (\\).
* **unzip** (*boolean*):  Option to unzip the downloaded zip file into the same directory. By default, it will unzip. Set this parameter to *FALSE* if you would like to not unzip the exported data after download.
* **server** (*string*): Prefix for the survey server. It is whatever comes before mysurvey.solutions: *[prefix]*.mysurvey.solutions.
* **user** (*string*): Username for the API user on the server.
* **password** (*string*): Password for the API user on the server.
* **tries** (*numeric*): Number of times to try getting an export before moving on to next one. Default is 10 times. If you are expecting the dataset on your servers to take a long time to export, increase the number of tries.


### Examples
I have a survey that uses the cloud server **lf2018.mysurvey.solutions** for data collection. I would like to get all the versions of the household questionnaire with the common title *LFS Survey HH*. I want the data in **tabular format** and I would like the data to be **unzipped after download**. I want to download the data into the folder: **C:/User/LF_Survey/Data/"**. On my server, I made an API user with the login: **APIuser2018** and password: **SafePassword123**. 

The list of questionnaires currently imported on my server looks like this:

| Title        | Version      | Variable
| ------------- |-------------|----------|
| LF Survey HH Q1    | 4 |    LFS_HH
| LF Survey HH Q1    | 5 |    LFS_HH
| LF Survey HH Q1    | 7 |    LFS_HH
| LF Survey HH Q2    | 10 |    LFS_HH
| LF Survey HH Q2    | 11 |    LFS_HH
| LF Survey HH Q2    | 12 |    LFS_HH
| LF Survey COM      | 1 |    LFS_COMM
| LF Survey COM      | 2 |    LFS_COMM

To use **dl_allVers** to download the data for that questionnaire, after loading the **dl_allVers** function into the workspace, I would run the following code:

```R
dl_allVers(qx_name = "LF Survey HH Q2", export_type = "tabular", 
      folder = "C:/User/LF_Survey/Data/", unzip = TRUE, 
      server = "lf2018", user = "APIuser2018", password = "SafePassword123")
```

If I only wanted to keep version 11 and 12, I can specify the drop parameter so that version 10 is not exported. My code would look like this:

```R
dl_allVers(qx_name = "LF Survey HH Q2", drop = 10, 
      export_type = "tabular", 
      folder = "C:/User/LF_Survey/Data/", unzip = TRUE, 
      server = "lf2018", user = "APIuser2018", password = "SafePassword123")
```

Alternatively, I can specify the keep parameter to export version 11 and 12, like this: 

```R
dl_allVers(qx_name = "LF Survey HH Q2", keep = c(11,12), 
      export_type = "tabular", 
      folder = "C:/User/LF_Survey/Data/", unzip = TRUE, 
      server = "lf2018", user = "APIuser2018", password = "SafePassword123")
```


