#' Datensatz publizieren
#'
#' Funktion published Datensatz, verändert aber NICHT die Sicherheitseinstellung (Datensatz nur für zugelassene Benutzer sichtbar)
#'
#' @template dataset_uid
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
   res <-httr::POST(url = paste0('https://',domain,'/api/',api_type,'/datasets/',dataset_uid,'/publish'),
              query = list(apikey=key))

   if (res$status_code != 200){
     Sys.sleep(4)
     res <-httr::POST(url = paste0('https://',domain,'/api/',api_type,'/datasets/',dataset_uid,'/publish'),
                      query = list(apikey=key))
   }
  },
  error = function(cond){
    stop("Publishing process failed")
  })

  if (res$status_code!=200){
    stop("Publishing process failed")
  }


}
