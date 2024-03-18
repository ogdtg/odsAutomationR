#' Create new dataset from metadata list
#'
#' @description With this function you can easily copy and customize metadata from existing sources to create a new dataset. You can call the get_metadata() function, edit the value you want and set the new metadata directly from the metadata_df.
#'
#' @param metadatalist a list as received from get_metadata()
#' @param id_part the dataset id without the number (for example "sk-stat")
#'
#' @return dataset_uid from the created dataset
#' @export
#'
create_dataset_from_list <- function(metadata_list,id_part){

  metadata_cat <- get_catalog()

  dataset_id <- create_new_dataset_id(id_part,save_local = F, metadata_cat = metadata_cat)

  metadata_list$custom$tags$value <- as.list(metadata_list$custom$tags$value)
  metadata_list$default$geographic_reference$value <- as.list(metadata_list$default$geographic_reference$value)
  metadata_list$internal$theme_id$value <- as.list(metadata_list$internal$theme_id$value)
  metadata_list$default$attributions$value <- as.list(metadata_list$default$attributions$value)

  meta_list <- list(dataset_id = dataset_id,
                    is_restricted = TRUE,
                    metadata=metadata_list)

  res <- httr::POST(url = paste0("https://", getDomain(),
                                 "/api/", getApiType(), "/datasets/"), query = list(apikey = getKey()),
                    body = jsonlite::toJSON(meta_list, auto_unbox = T),
                    httr::accept_json(), httr::content_type_json())
  metas <- res$content %>% rawToChar() %>% jsonlite::fromJSON()
  if (res$status_code == 201) {
    return(metas$uid)
  }
  else {
    warning(paste0("API returned Status Code:", res$status_code,
                   " ", metas$message))
    return(NULL)
  }

}

