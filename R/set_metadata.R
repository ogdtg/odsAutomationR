#' set_metadata
#'
#' Funktion um einen Eintrag in den Metadaten zu ändern
#'
#' @template dataset_uid
#' @template meta_name
#' @template meta_value
#' @template template
#'
#' @export
#'
#' @return `TRUE` if call was successfull, `NULL` otherwise
#'
set_metadata <- function(dataset_uid,template,meta_name,meta_value) {

  tryCatch({
    key = getKey()
    domain = getDomain()
    api_type = getApiType()
  },
  error = function(cond) {
    stop("Not all variables initilised. Use the set functions to set variables.")

  })



  final_list = list(
    value = meta_value
  )


  res <- httr::PUT(url = paste0("https://", getDomain(),
                                "/api/", getApiType(), "/datasets/",dataset_uid,"/metadata/",template,"/",meta_name,"/"), query = list(apikey = getKey()),
                   body = jsonlite::toJSON(final_list, auto_unbox = T),
                   httr::accept_json(), httr::content_type_json())
  metas <- res$content %>% rawToChar() %>% jsonlite::fromJSON()
  if (res$status_code == 200) {
    return(TRUE)
  }
  else {
    warning(paste0("API returned Status Code:", res$status_code,
                   " ", metas$message))
    return(NULL)
  }
}
