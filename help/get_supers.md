## Get data frame of supervisors on the server

### Description
Returns a data frame that has information on all the supervisors that are currently on the server. Due to the current limitations of the API, only supervisors that are not archived/locked appear in the output data frame.
The data frame will have the following columns:
* **SuperName**: User name of supervisors
* **SuperId**: Unique ID of supervisors
* **IsLocked**: If supervisor is currently locked/archived
* **CreationDate**: Date the supervisor account was created
* **DeviceId**: Unique Id of the tablet that the user was using on the last synchronisation to server. If the user has never synced any data with the server using a tablet, this variable will be null.

### Usage
```R
get_supers(server, user, password)

```

### Arguments
* **server** (*string*): Prefix for the survey server. It is whatever comes before mysurvey.solutions: *[prefix]*.mysurvey.solutions.
* **user** (*string*): Username for the API user on the server.
* **password** (*string*): Password for the API user on the server.