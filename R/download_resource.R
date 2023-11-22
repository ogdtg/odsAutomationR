#' Download dataset resource
#'
#' @template dataset_uid
#' @template resource_uid
#' @template encoding
#'
#' @return Downloaded (CSV-) resource
#' @export
#'
#'
download_resource = function(dataset_uid, resource_uid = NULL, encoding = "UTF-8") {
  tryCatch({
    key = getKey()
    domain = getDomain()
    api_type = getApiType()
  },
  error = function(cond) {
    stop("Not all variables initilised. Use the set functions to set variables.")

  })

  resource_info <- get_dataset_resource(dataset_uid)

  if (is.null(resource_uid)){
    if (resource_info$total_count>1){
      warning("More than one resource. Will download the newest csvfile")
    } else if (resource_info$total_count==0){
      stop("No Resource to download")
    }
  }



  file_uid <- resource_info$results[resource_info$results$type=="csvfile"]$datasource$file$uid[1]


  res <- httr::GET(url = paste0('https://',domain,'/api/',api_type,'/datasets/',dataset_uid,'/resources/files/',file_uid,'/download/'),
                   query = list(apikey = getKey()))

  result  <- httr::content(res,as = "parsed", encoding = encoding)
  return(result)

}
