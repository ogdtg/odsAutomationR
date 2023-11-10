#' Datensatz Veröffentlihung rückgängig machen
#'
#' Funktion unpublished Datensatz, verändert aber NICHT die Sicherheitseinstellung (Datensatz nur für zugelassene Benutzer sichtbar)
#'
#' @param encoding File encoding
#'
#' @export
#'
unpublish_dataset <- function(dataset_uid) {
  tryCatch({
    key = getKey()
    domain = getDomain()
    api_type = getApiType()
  },
  error = function(cond) {
    stop("Not all variables initilised. Use the set functions to set variables.")

  })

  tryCatch({
    httr::POST(url = paste0('https://',domain,'/api/',api_type,'/datasets/',dataset_uid,'/unpublish'),
               query = list(apikey=key))
  },
  error = function(cond){
    stop("Publishing process failed")
  })


}
