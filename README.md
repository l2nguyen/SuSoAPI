# SuSoAPI

Different functions that use the Survey Solutions API to different functions. Currently, there is only functions to download data.

## Functions currently available:
* **dl_one**: Downloads the data for the specified version for the specified questionnaire
* **dl_similar**: Downloads the data for all questionnaire that matches a specified pattern. Can use regex patterns.
* **dl_allvers**: Downloads all versions of the specified questionnaire.
* **get_qx**: Gets information about all the questionnaires imported on the server
* **get_qx_id**: Returns the template ID of the specified questionnaire