## Archive/Unarchive assignments

### Description
Two functions to archive and unarchive assignments on the server.

### Usage
```R
# archive assignments
archive_asgmts(ids=NULL, server, user, password)
# unarchive assignments
unarchive_asgmts(ids=NULL, server, user, password)
```

### Arguments
* **ids** (*integer* or vector of *integer*): Assignment IDs to archive or unarchive. This can be a vector so multiple assignments can be archived or unarchived in a batch.
* **server** (*string*): Prefix for the survey server. It is whatever comes before mysurvey.solutions: *[prefix]*.mysurvey.solutions.
* **user** (*string*): Username for the API user on the server.
* **password** (*string*): Password for the API user on the server.