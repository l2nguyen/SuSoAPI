# Survey Solutions API

Different functions that use the Survey Solutions API to different functions. Currently, there is only functions to download data.

## Getting Started
### Prerequisites
These programs uses R to interact with the Survey Solutions API so you will need to install R and R Studio on your computer.

* [R](https://cran.rstudio.com/)
* [RStudio](https://www.rstudio.com/products/rstudio/download/)

You will also need to make an API user account on your survey server. Learn how to make an API user account on the [support page](http://support.mysurvey.solutions/customer/en/portal/articles/2844104-survey-solutions-api?b_id=12728)

### How to use?
Download the the repository by clicking on the green *Clone or download* button on the right side under the respository name.This will download all the code and read me files onto your computer in a zip file.

## Description of functions currently available:
* [dl_one](help/dl_one.md): Downloads the data for the specified version for the specified questionnaire
* **dl_similar**: Downloads the data for all questionnaire that matches a specified pattern. Can use regex patterns.
* **dl_allvers**: Downloads all versions of the specified questionnaire.
* **get_qx**: Gets information about all the questionnaires imported on the server
* **get_qx_id**: Returns the template ID of the specified questionnaire
