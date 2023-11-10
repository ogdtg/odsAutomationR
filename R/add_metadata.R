#' Add Metadata field
#'
#' @description
#' Adds a metadata field (might be deprecated in the future)
#'
#'
#' @template template_params
#' @param meta_df 4
#'
#' @return TRUE or NULL
#' @export
#'
#'
add_metadata <- function(dataset_uid,template=NULL,meta_name=NULL ,meta_value=NULL, meta_df = NULL){

  metas_list <- get_metadata(dataset_uid=dataset_uid, as_list = T)


  if (!is.null(meta_df)){
    for (i in 1:nrow(meta_df)){
      metas_list[[meta_df$template[i]]][[meta_df$meta_name[i]]] <- meta_df$meta_value[i]

    }
  } else if (is.null(template)|is.null(meta_name)|is.null(meta_value)){
    stop("template, meta_name and meta_value must be provided")
  } else {
    metas_list[[template]][[meta_name]][["value"]] <- meta_value
  }

  res <- httr::PUT(url = paste0("https://", getDomain(),
                                "/api/", getApiType(), "/datasets/",dataset_uid,"/metadata/"), query = list(apikey = getKey()),
                   body = jsonlite::toJSON(metas_list, auto_unbox = T),
                   httr::accept_json(), httr::content_type_json())


  response <- res$content %>% rawToChar() %>% jsonlite::fromJSON()

  if (res$status_code == 200) {
    return(TRUE)
  }
  else {
    warning(paste0("API returned Status Code:", res$status_code,
                   " ", response$message))
    return(NULL)
  }
}
