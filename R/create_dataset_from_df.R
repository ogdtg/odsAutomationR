#' Create new dataset from metadata data.frame
#'
#' @description With this function you can easily copy and customize metadata from existing sources to create a new dataset. You can call the get_metadata() function, edit the value you want and set the new metadata directly from the metadata_df.
#'
#' @param metadata_df a data.frame as received from get_metadata()
#' @param id_part the dataset id without the number (for example "sk-stat")
#'
#' @return dataset_uid from the created dataset
#' @export
#'
create_dataset_from_df <- function(metadata_df,id_part){

  metadata_cat <- get_catalog()

  if (length(metadata_df$value[metadata_df$name=="theme_id"][[1]])==1){
    metadata_df$value[metadata_df$name=="theme_id"][[1]] <- list(metadata_df$value[metadata_df$name=="theme_id"][[1]])
  }
  if (length(metadata_df$value[metadata_df$name=="attributions"][[1]])==1){
    metadata_df$value[metadata_df$name=="attributions"][[1]] <- list(metadata_df$value[metadata_df$name=="attributions"][[1]])
  }
  if (length(metadata_df$value[metadata_df$name=="tags"][[1]])==1){
    metadata_df$value[metadata_df$name=="tags"][[1]] <- list(metadata_df$value[metadata_df$name=="tags"][[1]])
  }
  if (length(metadata_df$value[metadata_df$name=="keyword"][[1]])==1){
    metadata_df$value[metadata_df$name=="keyword"][[1]] <- list(metadata_df$value[metadata_df$name=="keyword"][[1]])
  }



  dataset_id <- create_new_dataset_id(id_part,save_local = F, metadata_cat = metadata_cat)

  meta_list <- list(dataset_id = dataset_id,
                    is_restricted = TRUE,
                    metadata=NULL)

  for (i in seq_along(metadata_df$value)) {
    meta_list[["metadata"]][[metadata_df$template.name[i]]][[metadata_df$name[i]]][["value"]] <- metadata_df$value[i][[1]]
  }
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
