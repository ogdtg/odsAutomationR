#' Get dataset fields
#'
#' @description Retrieves the fields of the dataset including name, type, annotations and description
#'
#' @template dataset_uid
#'
#' @return a data.frame containing the fields informatin
#' @export
#'
get_fields <- function(dataset_uid){
  resource_info <- get_dataset_resource(dataset_uid)

  if (length(resource_info)<4){
    stop("No resource present")
  }
  if (nrow(resource_info$results)>1){
    resource_uid <- resource_info$results$uid[which(resource_info$results$type == "csvfile")][1]
  } else {
    resource_uid <- resource_info$results$uid

  }

  res <- httr::GET(url = paste0('https://',getDomain(),'/api/',getApiType(),'/datasets/',dataset_uid,"/resources/",resource_uid,"/preview/"),
                     query = list(apikey=getKey()))

  result <- res$content %>% rawToChar() %>% jsonlite::fromJSON()
  return(result$fields)

}


