#' Datensatz publizieren
#'
#' Funktion published Datensatz, verändert aber NICHT die Sicherheitseinstellung (Datensatz nur für zugelassene Benutzer sichtbar)
#'
#' @param dataset_uid kann metadata_catalog entnommen werden
#' @importFrom httr PUT
#'
#' @export
#'
publish_dataset <- function(dataset_uid) {
  tryCatch({
    key = getKey()
    domain = getDomain()
    api_type = getApiType()
  },
  error = function(cond) {
    stop("Not all variables initilised. Use the set functions to set variables.")

  })

  tryCatch({
   httr::POST(url = paste0('https://',domain,'/api/',api_type,'/datasets/',dataset_uid,'/publish'),
              query = list(apikey=key))
  },
  error = function(cond){
    stop("Publishing process failed")
  })


}
