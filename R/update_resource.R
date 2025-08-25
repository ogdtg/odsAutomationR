#' update_resource
#'
#' Resource eines Datensatzes ersetzen mit bereits hochgeladenem File
#'
#' @template dataset_uid
#' @template encoding
#' @template filepath
#' @template resource_uid
#' @param separator
#'
#' @export
#'
update_resource <-  function(dataset_uid, resource_uid = NULL,filepath, encoding,separator = NULL){




  if (is.null(resource_uid)) {
    resource_info <- get_dataset_resource(dataset_uid = dataset_uid)
    if (length(resource_info$results)==0) {
      message("There is no resource to update. Will add new resource")

      resource_uid <- add_file_to_dataset(filepath = filepath, dataset_uid = dataset_uid, encoding = encoding,separator = separator)
      return(resource_uid)
    }

    if (length(resource_info$results$uid)>1) {
      warning("multiple resources and no resource_uid provided by user. Will update the last updated resource")
    }

    resource_uid <- resource_info$results$uid[nrow(resource_info$results)]

    if (grepl("^http", filepath)) {
      delete_resource(dataset_uid = dataset_uid,resource_uid = resource_uid)
      resource_id <- add_file_to_dataset(filepath=filepath,dataset_uid=dataset_uid,encoding=encoding,separator=separator)
      return(resource_id)
    }


  }



  results <- upload_file_to_ods(filepath = filepath, dataset_uid = dataset_uid)


  body <- list(
    type = "csvfile",
    title = results$filename,
    params = list(
      doublequote = T,
      encoding = encoding,
      separator = ","
    ),
    datasource = list(type = "uploaded_file", file = list(uid = results$uid))
  ) %>%
    jsonlite::toJSON(auto_unbox = T, null = "null")




  res <- httr::PUT(url = paste0("https://",getDomain(),"/api/",getApiType(),"/datasets/",dataset_uid,"/resources/",resource_uid,"/"),
             body = body,
             query = list(apikey = getKey()),
             httr::accept_json(),
             httr::content_type_json())

  if (res$status_code %in% c(200,201,204)){
    return(resource_uid)
  } else{
    return(NULL)
  }


}
