#' Update the dataset resource
#'
#' @param filepath path to csv file
#' @param dataset_uid dataset_uid
#' @param encoding encdoing of the csv file
#'
#' @return resource_uid
#' @export
#'
update_dataset_resource <- function(filepath,dataset_uid,resource_uid,encoding){

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

  body <- list(type = "csvfile",
               title = result$filename,
               params = list(doublequote = T,
                             encoding = encoding,
                             separator = ","),
               datasource = list(type = "uploaded_file",
                                 file = list(uid = result$uid))) %>%
    jsonlite::toJSON(auto_unbox = T)


  res <- httr::PUT(url = paste0('https://',domain,'/api/',api_type,'/datasets/',dataset_uid,"/resources/",resource_uid), body = body,
                    query=list(apikey=key),
                    httr::accept_json(),
                    httr::content_type_json())

  result_final <- res$content %>% rawToChar() %>% jsonlite::fromJSON()


  if(res$status_code=="200"){
    return(result_final$uid)
  } else {
    stop(paste0("API Error: ",res$status_code," ",result_final$message))
  }
}
