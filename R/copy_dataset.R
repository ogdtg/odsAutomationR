#' Copy a dataset
#'
#' Copy all data and metadata from one dataset to another
#'
#' @template template_params
#'
#' @return metadata of the newly created dataset
#' @export
#'
copy_dataset <- function(dataset_uid){
  tryCatch({
    key = getKey()
    domain=getDomain()
    api_type = getApiType()
  },
  error = function(cond){
    stop("Not all variables initilised. Use the set functions to set variables.")

  })
  if (api_type == "management/v2"){
    return(NULL)
  } else {
    res <- httr::POST(url = paste0("https://",domain,"/api/",api_type,"/datasets/",dataset_uid,"/copy/"),
               query = list(apikey=key))
    metas <- res$content %>% rawToChar() %>% jsonlite::fromJSON()
    return(metas)
  }

}
