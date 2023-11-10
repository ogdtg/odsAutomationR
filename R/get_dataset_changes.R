#' get_dataset_changes
#'
#' Datensatz Historie herunterladen
#'
#' @template template_params
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

  red_result <- result$results
  red_result$dataset_uid <-dataset_uid
  names(red_result)[names(red_result)=="created_at"] <- "timestamp"
  names(red_result)[names(red_result)=="uid"] <- "change_uid"



  return(red_result)





}
