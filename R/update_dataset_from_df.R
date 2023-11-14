#' Update dataset with metadata data.frame
#'
#' @description With this function you can easily update metadata of an existing dataset. You can call the get_metadata() function, edit the value you want and set the new metadata directly from the metadata_df.
#'
#' @template dataset_uid
#' @param metadata_df a data.frame as received from get_metadata()
#' @param id_part the dataset id without the number (for example "sk-stat")
#' @param dataset_id full dataset_id (e.g. sk-stat-100). It is recommendend to just provide the id_part
#' @param is_restricted whether the data.frame should be restricted and only be visible for backend user for (default is TRUE)
#'
#' @return dataset_uid from the created dataset
#' @export
#'
update_dataset_from_df <- function(dataset_uid, metadata_df,id_part = NULL, dataset_id = NULL, is_restricted = TRUE){

  metadata_cat <- get_catalog()

  if (is.null(dataset_id) & is.null(id_part)){
    stop("You must either provide a full dataset_id or an id_part to create a new dataset_id")
  }

  if (!is.null(id_part)){
    dataset_id <- create_new_dataset_id(id_part,save_local = F, metadata_cat = metadata_cat)
  }
  if (!is.null(dataset_id)){
    dataset_id <- dataset_id
  }



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




  meta_list <- list(dataset_id = dataset_id,
                    is_restricted = is_restricted,
                    metadata=NULL)

  for (i in seq_along(metadata_df$value)) {
    meta_list[["metadata"]][[metadata_df$template.name[i]]][[metadata_df$name[i]]][["value"]] <- metadata_df$value[i][[1]]
  }
  res <- httr::PUT(url = paste0("https://", getDomain(),
                                 "/api/", getApiType(), "/datasets/",dataset_uid), query = list(apikey = getKey()),
                    body = jsonlite::toJSON(meta_list, auto_unbox = T),
                    httr::accept_json(), httr::content_type_json())
  metas <- res$content %>% rawToChar() %>% jsonlite::fromJSON()
  if (res$status_code == 200) {
    return(metas)
  }
  else {
    warning(paste0("API returned Status Code:", res$status_code,
                   " ", metas$message))
    return(NULL)
  }

}
