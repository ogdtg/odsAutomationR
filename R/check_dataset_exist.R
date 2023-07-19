#' check_dataset_exist
#'
#' Überprüft ob ein Datensatz mit der gegebenen dataset_uid existiert
#'
#' @param dataset_uid kann metadata_catalog entnommen werden
#'
#' @return boolean: wenn Datensatz existiert TRUE sonst FALSE
#' @export
#'
check_dataset_exist <- function(dataset_uid){
  tryCatch({
    key = getKey()
    domain = getDomain()
    api_type = getApiType()
  },
  error = function(cond) {
    stop("Not all variables initilised. Use the set functions to set variables.")

  })
  res <- httr::GET(url = paste0("https://",domain,"/api/",api_type,"/datasets/",dataset_uid,"/status/"),
             query = list(apikey=key))

  if (res$status_code==200){
    return(TRUE)
  } else {
    return(FALSE)
  }

}

