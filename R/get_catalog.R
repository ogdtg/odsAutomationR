#' Get detailed Meta Data
#'
#' @param dataset_uid dataset_uid
#' @param variables list of variables that should be downloaded
#'
#' @description Function to retrieve meta data from the backend. This function is for internal use only. An API key must be specified and passed to the function.
#' @return dataframe containing the meta data.
#'
#' @export
#'
#'
get_catalog = function(dataset_uid = NULL, variables = NULL){
  tryCatch({
    key = getKey()
    domain = getDomain()
    api_type = getApiType()
  },
  error = function(cond) {
    stop("Not all variables initilised. Use the set functions to set variables.")

  })

  if (is.null(variables)){
    select <- "dataset_id%2Ctitle%2Cdataset_uid"
  } else {
    select <- paste0("dataset_id,title,dataset_uid,",variables, collapse = "," )
    select <- gsub(",","%2C",select)
  }

  offset = 0
  limit = 100
  if (is.null(dataset_uid)){
    link <- glue::glue("https://{domain}/api/explore/v2.1/catalog/datasets?apikey={key}&select={select}&limit={limit}&offset={offset}&timezone=UTC&include_links=false&include_app_metas=false")
  } else {
    link <- glue::glue("https://{domain}/api/explore/v2.1/catalog/datasets?apikey={key}&select={select}&where=dataset_uid%3D%22{dataset_uid}%22&limit=1&offset={offset}&timezone=UTC&include_links=false&include_app_metas=false")
    res = httr::GET(link)
    result=jsonlite::fromJSON(rawToChar(res$content), flatten = TRUE)
    if (res$status_code==200){
      return(result$results)
    } else{
      return(result)
    }
  }

  counter <- 100
  res = httr::GET(link)
  result=jsonlite::fromJSON(rawToChar(res$content), flatten = TRUE)
  if (res$status_code!=200){
    stop(paste0("API returned an error (status code: ",res$status_code,"): ",result$error_code,": ",result$message))
  }
  total_datasets <- result$total_count


  df_list <- list(result$results)
  while(counter<=total_datasets){
    offset = offset+100
    counter = counter +limit
    link <- glue::glue("https://{domain}/api/explore/v2.1/catalog/datasets?apikey={key}&select={select}&limit={limit}&offset={offset}&timezone=UTC&include_links=false&include_app_metas=false")
    res = httr::GET(link)
    df_list[[paste0(counter)]]=jsonlite::fromJSON(rawToChar(res$content), flatten = TRUE) %>% .$results



  }


  test <- do.call(rbind, df_list)
  rownames(test) <- NULL
  return(test)




}

