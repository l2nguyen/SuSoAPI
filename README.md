# Survey Solutions API

Wrapper functions for Survey Solutions API.

## Description of functions currently available:
* [dl_one](dl_one.R): Downloads the data for the specified version for the specified questionnaire.  [How to use.](help/dl_one.md)
* [dl_allVers](dl_allvers.R): Downloads all versions of the specified questionnaire. [How to use.](help/dl_allvers.md)
* [dl_similar](dl_similar.R): Downloads the data for all questionnaire that matches a specified pattern. Can use regex patterns. [How to use.](help/dl_similar.md)
* [get_qx](get_qx.R): Gets information about all the questionnaires imported on the server.  [How to use.](help/get_qx.md)
* [get_qx_id](get_qx_id.R): Returns the template ID of the specified questionnaire.
* [get_asgmts_list](get_asgmts_list.R): Returns all the assignments on the server for a version of a questionnaire. [How to use.](help/get_asgmts_list.md)
* [archive_asgmts](archive_asgmts.R): Archive assignments. [How to use](help/archive_asgmts.md)
* [get_supers](get_supers.R): Returns information about all the supervisors on the server. Due to current limitations of the API, only supervisors that are not archived/locked will appear in the data. [How to use](help/get_supers.md)
* [get_interviewers](get_interviewers.R): Returns information about all the interviewers for specified supervisors. Due to current limitations of the API, only interviewers that are not archived/locked will appear in the data. 

## Getting Started
### Prerequisites
These programs uses R to interact with the Survey Solutions API so you will need to install R and R Studio on your computer.

* [R](https://cran.rstudio.com/)
* [RStudio](https://www.rstudio.com/products/rstudio/download/)

You will also need to make an API user account on your survey server. Learn how to make an API user account on the [support page](http://support.mysurvey.solutions/customer/en/portal/articles/2844104-survey-solutions-api?b_id=12728).

### How to use?
Download the the repository by clicking on the green **Clone or download** button on the right side under the respository name and selecting *Download Zip*. This will download all the code and read me files onto your computer in a zip file.

You can use the functions in one of three ways:
1. Run the R file for the function in R Studio by opening it and pressing **Ctrl+Shift+Enter**. This will run all the code for the function in the file and now the function will be in the working environment for use in the working environment.
2. In the menu, go to **Code -> Source File...** or use the **Ctrl+Alt+G** keyboard shortcut. Select the function you would like to use and now it will be available for use in the working environment.
3. To load the function at the beginning of your code, use the [source function](https://www.rdocumentation.org/packages/base/versions/3.5.3/topics/source).

#### Server Details
If you are using the functions to download the same type of data from the same server, you should make a serverDetails.R file to save time. Fill in this [template](serverDetails.R) with details on your server and login for the API user.

#### Running R code in Stata
It is possible to call R code in Stata using the [rcall package](https://github.com/haghish/rcall). Installation information is available on the package's github.

This package allows R and Stata to interact and exchange data so it is possible to use these API functions in Stata with rcall. However, this will require writing a script in R to download the data from the API. Use it only after reading the documentation for rcall thoroughly.
