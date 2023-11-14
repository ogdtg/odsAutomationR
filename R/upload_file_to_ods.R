#' Uploads a file to ODS
#'
#' @template dataset_uid
#' @template filepath
#'
#' @return results list
#' @export
#'
upload_file_to_ods <- function(dataset_uid,filepath){

  tryCatch({
    key = getKey()
    domain = getDomain()
    api_type = getApiType()
  },
  error = function(cond) {
    stop("Not all variables initilised. Use the set functions to set variables.")

  })

  files = list(
    `file` = httr::upload_file(filepath)
  )

  res <- httr::POST(url = paste0('https://',domain,'/api/',api_type,'/datasets/',dataset_uid,"/resources/files"), body = files, encode = 'multipart',
                    query=list(apikey=key))


  result <- res$content %>% rawToChar() %>% jsonlite::fromJSON()
  return(result)

}
