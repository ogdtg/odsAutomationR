#' get_dataset_resource
#'
#' @template template_params
#'
#' @return Datensatz mit allen Datenquellen die dem entsprechenden ODS Datensatz zugeordnet sind
#' @export
#'
#'
get_dataset_resource = function(dataset_uid){
  tryCatch({
    key = getKey()
    domain = getDomain()
    api_type = getApiType()
  },
  error = function(cond) {
    stop("Not all variables initilised. Use the set functions to set variables.")

  })

  res <- httr::GET(url = paste0('https://',domain,'/api/',api_type,'/datasets/',dataset_uid,"/resources"),
                   query = list(apikey=key))

  result <- res$content %>% rawToChar() %>% jsonlite::fromJSON()
  return(result)

}
