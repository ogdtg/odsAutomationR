#' get_dataset_status
#'
#' Datensatz Status herunterladen
#'
#' @template template_params
#'
#' @return Name des dataset_status
#' @export
#'
#' @importFrom jsonlite fromJSON
#' @importFrom httr GET
#'
get_dataset_status = function(dataset_uid){
  tryCatch({
    key = getKey()
    domain = getDomain()
    api_type = getApiType()
  },
  error = function(cond) {
    stop("Not all variables initilised. Use the set functions to set variables.")

  })

  res <- httr::GET(url = paste0('https://',domain,'/api/',api_type,'/datasets/',dataset_uid,"/status"),
                   query = list(apikey=key))

  result <- res$content %>% rawToChar() %>% jsonlite::fromJSON()

  names(result)[1] <- "status"

  return(result$status)
}
