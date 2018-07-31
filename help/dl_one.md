## Export data from one template
### Description
Exports data from a version of the specified questionnaire using the Survey Solutions API. The function check the status of the download 5 times and wait progressively longer every time it checks for the export to finish.
### Usage
dl_one(qx_name, version = 1, export_type = 'tabular', 
		folder, unzip = TRUE, 
		server, user = 'APIuser', password = 'Password123')