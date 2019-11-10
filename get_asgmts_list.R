get_asgmts_list <- function(template_id = NULL, # template id
                            qx_name = NULL, # questionnaire name
                            version = NULL, # version
                            responsible = "", # by default, find all
                            archived = FALSE, # by default, not archived
                            output = "df", # options: tab, data frame or excel
                            output_path = NULL, # output file name
                            server, # server prefix
                            user, # API user username
                            password) # password for API user
{

  # -------------------------------------------------------------
  # Load all necessary functions and require packages
  # -------------------------------------------------------------

  load_pkg <- function(x) {
    if (!require(x, character.only = TRUE)) {
      install.packages(x, repos = 'https://cloud.r-project.org/', dep = TRUE)
    }
    require(x, character.only = TRUE)
  }

  load_pkg('dplyr')
  load_pkg('jsonlite')
  load_pkg('httr')
  load_pkg('tidyr')
  load_pkg('readr')
  load_pkg('writexl')
  load_pkg('here')

  # -------------------------------------------------------------
  # CHECK ALL INPUTS
  # -------------------------------------------------------------

  # check that server, login, password are non-missing
  for (x in c("server", "user", "password")) {
    if (!is.character(get(x))) {
      stop(x, "has to be a string.")
    }
    if (nchar(get(x)) == 0) {
      stop(paste("The following parameter is not specified in the program:", x))
    }
  }

  # Check output is a valid output data type
  if (tolower(output) %in% c("df", "tab", "excel") == FALSE) {
    stop("Output has to be either df (data frame), tab, or excel.")
  }

  # confirm that output path was specified
  if ((tolower(output) %in% c("tab", "excel")) & is.null(output_path)) {
    stop("Specify output path for tab or excel output.")
  }

  # check if archived is logical
  if (!is.logical(archived)){
    stop("Specify either TRUE or FALSE for archived status.")
  }

  # check version is numeric
  if (!is.numeric(version)) {
    if (is.null(version)){
      stop("Specify version number.")
    } else if (is.na(as.numeric(version))) {
      stop("Version number ", version, " is not numeric.")
    } else {
      version <- as.numeric(version)
    }
  }

  if(is.null(qx_name) & is.null(template_id)){
    stop("Either qx_name or template_id must be specified.")
  }
  # check that not both qx name and template id is specified
  if(!is.null(qx_name) & !is.null(template_id)){
    stop("Specify only either qx_name or template_id.")
  }

  # -------------------------------------------------------------
  # Get template id if only questionnaire name is specified
  # -------------------------------------------------------------
  if (!is.null(qx_name) & is.null(template_id)){
    # load get_qx
    source(here::here("get_qx.R"))

    # trim white space around name
    qx_name <- trimws(qx_name)

    # get the list of questionnaires on the server
    all_qx <- get_qx(server=server, user=user,
                     password=password, put_global=FALSE)

    # Get ID of template to get export URL
    qx_match <- dplyr::filter(all_qx, Title==qx_name, Version==version)

    if (nrow(qx_match)==1) {
      qx_id <- qx_match$QuestionnaireIdentity
    } else {
      stop("Could not find questionnaire on server. Check questionnaire name and version number is correct.")
    }
  }

  # -------------------------------------------------------------
  # Call API
  # -------------------------------------------------------------

  # build base URL for API
  server <- tolower(trimws(server))

  api_url <- sprintf("https://%s.mysurvey.solutions/api/v1",
                     server)

  # build api endpoint
  endpoint <- paste0(api_url, "/assignments")

  # build template id for query
  # if qx name specified, used qx_id
  if (!is.null(template_id)){
    qid = paste0(template_id, '$', version)
  } else if (!is.null(qx_name)){
    qid = qx_id
  }

  user_query <- list(questionnaireId = qid,
                     responsible = responsible,
                     showArchive = archived)

  # Send GET request to API
  data <- httr::GET(endpoint, authenticate(login, password),
                    query = user_query)

  # save the list of imported templates from the API as a data frame
  assignments <- jsonlite::fromJSON(content(data, as = "text"))

  # get total count
  total_count <- assignments$TotalCount
  # get limit
  limit <- assignments$Limit

  n_calls <- ceiling(total_count/limit)

  # function to transform the id vars from list into columns
  transform_id_vars <- function(df){
    Id_vars <- df %>%
      dplyr::select(Id, IdentifyingQuestions) %>%
      tidyr::unnest(cols = c(IdentifyingQuestions)) %>%
      dplyr::select(-Identity) %>%
      tidyr::spread(Variable, Answer)

    df_with_id <- dplyr::left_join(df, Id_vars, by = 'Id')

    df_with_id  <- df_with_id  %>%
      dplyr::select(-ResponsibleId, -QuestionnaireId, -IdentifyingQuestions)

    return(df_with_id)
  }

  # initiate empty list for output
  df_list <- list()

  # Send post query for all the data
  for (i in 1:n_calls){
    # build user query with offset
    user_query_loop <- list(questionnaireId = qid,
                            responsible = responsible,
                            showArchive = archived,
                            offset = (20 * (i-1))
    )

    # Send GET request to API
    resp <- httr::GET(endpoint, authenticate(login, password),
                      query = user_query_loop)

    # save the list of imported templates from the API as a data frame
    assignments <- jsonlite::fromJSON(content(resp, as = "text"))

    # if call to api was unsuccesful, stop
    if (status_code(resp) != 200) {
      stop(paste0('API request failed with code', status_code(resp)))
    }

    assignments_temp <- as.data.frame(assignments$Assignments)

    # transform identifyng variable from list to column
    assignments_id <- transform_id_vars(assignments_temp)

    df_list[[i]] <- assignments_id
  }

  # bind all output together into a big dataframe
  if (length(df_list)==1){
    all_assignments <- df_list[[1]]
  } else {
    all_assignments <- dplyr::bind_rows(df_list)
    }

  if (output == "tab"){
    readr::write_tsv(all_assignments, path=output_path)
  } else if (output == "excel") {
    writexl::write_xlsx(all_assignments, path=output_path,
                        format_headers=FALSE)
  } else {
    # return data frame if not exporting to tab or excel
    return(all_assignments)
  }
}
