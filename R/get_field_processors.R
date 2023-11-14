#' get_field_processors
#'
#' Funktion um alle processor Schritte (Umbenennungen, Veränderung Beschreinung, Veränderung Typ,etc.) eines Datensatzes anzuzeigen
#'
#' @template dataset_uid
#' @param limit number of field processors (default is `NULL`)
#'
#' @return dataframe mit processor Schritten
#' @export
get_field_processors <- function(dataset_uid, limit=NULL) {
  if (is.null(limit)){
    limit <- 20
  }

  tryCatch({
    key = getKey()
    domain = getDomain()
    api_type = getApiType()
  },
  error = function(cond) {
    stop("Not all variables initilised. Use the set functions to set variables.")

  })

  res <-
    httr::GET(
      paste0(
        "https://",
        domain,
        "/api/",
        api_type,
        "/datasets/",
        dataset_uid,
        "/fields/"
      ),
      query = list(apikey = key, limit = limit),
      httr::accept_json(),
      httr::content_type_json()
    )
  result <- res$content %>% rawToChar() %>% jsonlite::fromJSON()
  return(result$results)


}
