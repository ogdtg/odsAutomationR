#' get_dataset_changes
#'
#' Datensatz Historie herunterladen
#'
#' @param dataset_uid Datensatz ID
#'
#' @return Datensatz mit allen Datenquellen die dem entsprechenden ODS Datensatz zugeordnet sind
#' @export
#'

get_dataset_changes = function(dataset_uid){
  tryCatch({
    key = getKey()
    domain = getDomain()
    api_type = getApiType()
  },
  error = function(cond) {
    stop("Not all variables initilised. Use the set functions to set variables.")

  })

  endpoint = "/versions"

  res <-
    httr::GET(
      url = paste0(
        'https://',
        domain,
        '/api/',
        api_type,
        '/datasets/',
        dataset_uid,
        endpoint
      ),
      query = list(apikey = key,limit = 100)
    )

  result <- res %>% prepare_response()

  if (res$status_code != 200) {
    stop(paste0("API Call returned Error ", res$status_code))
  }

  red_results <- result$results
  red_results$dataset_uid <-dataset_uid
  names(red_results)[names(red_results)=="created_at"] <- "timestamp"
  names(red_results)[names(red_results)=="uid"] <- "change_uid"



  return(red_result)





}
