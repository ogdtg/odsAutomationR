#' get_field_processors
#'
#' Funktion um alle processor Schritte (Umbenennungen, Veränderung Beschreinung, Veränderung Typ,etc.) eines Datensatzes anzuzeigen
#'
#' @param dataset_uid kann metadata_catalog entnommen werden
#'
#' @return dataframe mit processor Schritten
#' @export
#'
#' @importFrom httr GET
#' @importFrom jsonlite fromJSON
#'
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

  if(api_type == "management/v2"){
    res <- httr::GET(paste0("https://",domain,"/api/",api_type,"/datasets/",dataset_uid,"/fields_specifications/"),
                     query = list(apikey=key))
    result <- res$content %>% rawToChar() %>% jsonlite::fromJSON()
    return(result)
  } else {
    res <- httr::GET(paste0("https://",domain,"/api/",api_type,"/datasets/",dataset_uid,"/fields/"),
                     query = list(apikey=key, limit = limit),
                     httr::accept_json(),
                     httr::content_type_json())
    result <- res$content %>% rawToChar() %>% jsonlite::fromJSON()
    return(result$results)
  }

}
