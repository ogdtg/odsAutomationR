#' restore_change
#'
#' Historie wiederherstellen
#'
#' @template template_params
#'
#' @export
#'
restore_change = function(dataset_uid, change_uid){
  tryCatch({
    key = getKey()
    domain = getDomain()
    api_type = getApiType()
  },
  error = function(cond) {
    stop("Not all variables initilised. Use the set functions to set variables.")

  })

  res <- httr::POST(
    url = paste0('https://',domain,'/api/',api_type,'/datasets/',dataset_uid,'/versions/',change_uid,"/restore/"),
    query = list(apikey=key),
    httr::content_type_json()
  )

  return(res$status_code)
}
