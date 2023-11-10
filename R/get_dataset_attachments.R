#' get_dataset_attachments
#'
#' Alle Anhänge eines Datensatzes anzeigen
#'
#' @template template_params
#'
#' @return Datensatz mit allen Datenquellen die dem entsprechenden ODS Datensatz zugeordnet sind
#' @export
#'

get_dataset_attachments = function(dataset_uid){
  tryCatch({
    key = getKey()
    domain = getDomain()
    api_type = getApiType()
  },
  error = function(cond) {
    stop("Not all variables initilised. Use the set functions to set variables.")

  })

  res <- httr::GET(url = paste0('https://',domain,'/api/',api_type,'/datasets/',dataset_uid,"/attachments"),
                   query = list(apikey=key))

  result <- res$content %>% rawToChar() %>% jsonlite::fromJSON() %>% .$results
  return(result)

}
