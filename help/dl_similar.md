## Downloads data for all questionnaires with similar names

### Description
Exports data from all questionnaires that match a provided pattern. Function uses [str_detect](https://www.rdocumentation.org/packages/stringr/versions/1.3.1/topics/str_detect) to match the pattern so a regular expression pattern can be used. Additionally, there is the option to exclude questionnaires that have certain words in them (ie training, practice). This function uses the [dl_one function](dl_one.md) so it has similar parameters. 

### Usage
```R
dl_similar(pattern, exclude = NULL, ignore.case = TRUE, 
      export_type = "tabular", folder, unzip = TRUE, 
      server, user = "APIuser", password = "Password123", tries = 10)
```

### Arguments
* **pattern** (*string* or list of strings): Pattern to match in the name of questionnaires to download. Can use regular expression for this.
* **exclude** (*string* or list of strings): Questionnaire names containing words in this exclude list will not be downloaded. By default, there are no exclusionary terms.
* **ignore.case** (*boolean*): Whether the match for pattern and exclusionary terms should be case sensistive. It is set to *TRUE* by default so the match is not case sensitive.
* **export_type** (*string*): The type of data to export. Options are tabular, stata, spss, binary, paradata. Default is tabular.
* **folder** (*string*): The directory to export the data into. Must be a string. Use forward slash (/) instead of backslash (\\).
* **unzip** (*boolean*):  Option to unzip the downloaded zip file into the same directory. By default, it will unzip. Set this parameter to *FALSE* if you would like to not unzip the exported data after download.
* **server** (*string*): Prefix for the survey server. It is whatever comes before mysurvey.solutions: *[prefix]*.mysurvey.solutions.
* **user** (*string*): Username for the API user on the server.
* **password** (*string*): Password for the API user on the server.
* **tries** (*numeric*): Number of times to try getting an export before moving on to next one. Default is 10 times. If you are expecting the dataset on your servers to take a long time to export, increase the number of tries.


### Examples
I have a survey that uses the cloud server **lf2018.mysurvey.solutions** for data collection. I want the data in **Stata format** and I would like the data to be **unzipped after download**. I want to download the data into the folder: **C:/User/LF_Survey/Data/"**. On my server, I made an API user with the login: **APIuser2018** and password: **SafePassword123**. 

The list of questionnaires currently imported on my server looks like this:

| Title        | Version      |
| ------------- |-------------|
| LF Survey HH Q1    | 1 |
| LF Survey HH Q1    | 2 |
| LF Survey HH Q1    | 3 |
| LF Survey HH Q2    | 1 |
| LF Survey HH Q2    | 2 |
| LF Survey COM      | 1 |
| LF Survey COM      | 2 |
| LF Survey HH TRAINING      | 1 |
| LF Survey HH TRAINING     | 2 |
| LF Survey HH PILOT     | 1 |

From this table, I can see that I have the following questionnaires imported: 
* Multiple versions of the household questionnaire from Quarter 1 (*LF Survey HH Q1*) and Quarter 2 (*LF Survey HH Q2*) of the survey
* Two versions of the community questionnaire (*LF Survey COM*)
* Two versions of the household questionnaire used for practice during the interviewer training (*LF Survey HH TRAINING*)
* One version of a household questionnaire used for the pilot (*LF Survey HH PILOT*).

Let's say I want to download all the data for all versions of the household questionnaire from both quarters of fieldwork but I do not want the data from the questionnaires used for the interviewer training or the pilot. Since I want to exclude multiple words, I want to put the strings into a vector. To make a vector with strings to use as exclusionary words, I will use the [c() function in R](http://www.r-tutor.com/r-introduction/vector). So to exclude the data from the questionnaire used in the training and the pilot, I will set the exclude paramenter to be `c("TRAINING", "PILOT")`. I can add as many strings as I want into this vector. 

The code to download the data I want using the **dl_similar** function would look like this:

```R
dl_similar(pattern = "HH", exclude = c("TRAINING", "PILOT"), ignore.case = TRUE, 
        export_type = "stata", folder = "C:/User/LF_Survey/Data/", unzip = TRUE, 
        server = "lf2018", user = "APIuser2018", password = "SafePassword123")
```

Since I set the `ignore.case` parameter to be `TRUE`, the match for the pattern and exclusion terms will not be case sensitive so this code would also work:

```R
dl_similar(pattern = "hh", exclude = c("training", "pilot"), ignore.case = TRUE, 
        export_type = "stata", folder = "C:/User/LF_Survey/Data/", unzip = TRUE, 
        server = "lf2018", user = "APIuser2018", password = "SafePassword123")
```

Now let's say I also want the data from the community questionnaire as well as the household questionnaire. I will once again make a list of strings by using the c() function in R. The pattern will not be set to this `c("hh", "comm")`. So now my code to download the data would look like this:
```R
dl_similar(pattern = c("hh", "com"), exclude = c("TRAINING", "PILOT"), ignore.case = TRUE, 
        export_type = "stata", folder = "C:/User/LF_Survey/Data/", unzip = TRUE, 
        server = "lf2018", user = "APIuser2018", password = "SafePassword123")
```
