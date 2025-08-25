#' Add CSV File to dataset
#'
#' Adds a local CSV file to a dataset on ODS (only possible with automation API)
#'
#' @template dataset_uid
#' @template encoding
#' @template filepath
#' @param encoding encdoing of the csv file
#' @param separator

#'
#' @return resource_uid
#' @export
#'
add_file_to_dataset <- function(filepath,dataset_uid,encoding,separator=NULL){

  if (grepl("^http", filepath)) {

    body <- list(
      type = "csvfile",
      title = filepath,
      params = list(
        doublequote = T,
        encoding = encoding,
        separator = separator
      ),
      datasource = list(type = "http",
                        connection = list(type = "http",
                                          url = sub("^(https?://[^/]+).*", "\\1", filepath),
                                          auth = list(type = "basic_auth",
                                                      username = "test",
                                                      password = "test")),
                        relative_url = sub("^https?://[^/]+", "", filepath))
    ) %>%
      jsonlite::toJSON(auto_unbox = T)

  } else {

    result <- upload_file_to_ods(dataset_uid=dataset_uid,filepath = filepath)

    body <- list(type = "csvfile",
                 title = result$filename,
                 params = list(doublequote = T,
                               encoding = encoding,
                               separator = ","),
                 datasource = list(type = "uploaded_file",
                                   file = list(uid = result$uid))) %>%
      jsonlite::toJSON(auto_unbox = T)

  }




  res <- httr::POST(url = paste0('https://',getDomain(),'/api/',getApiType(),'/datasets/',dataset_uid,"/resources/"), body = body,
                    query=list(apikey=getKey()),
                    httr::accept_json(),
                    httr::content_type_json())

  result_final <- res$content %>% rawToChar() %>% jsonlite::fromJSON()


  if(res$status_code=="201"){
    return(result_final$uid)
  } else {
    stop(paste0("API Error: ",res$status_code," ",result_final$message))
  }
}
