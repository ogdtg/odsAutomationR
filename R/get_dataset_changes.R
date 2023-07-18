#' get_dataset_changes
#'
#' Datensatz Historie herunterladen
#'
#' @param dataset_uid Datensatz ID
#'
#' @return Datensatz mit allen Datenquellen die dem entsprechenden ODS Datensatz zugeordnet sind
#' @export
#'
#' @importFrom jsonlite fromJSON
#' @importFrom httr GET
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

  if (api_type == "management/v2") {
    endpoint = "/changes"
  } else {
    endpoint = "/versions"
  }

  res <- httr::GET(url = paste0('https://',domain,'/api/',api_type,'/datasets/',dataset_uid, endpoint),
                   query = list(apikey=key))

  result <- res %>% prepare_response()

  if(res$status_code != 200) {
    stop(paste0("API Call returned Error ",res$status_code))
  }

  if (api_type == "management/v2") {
    red_result <- result %>%
      select(change_uid, timestamp,can_restore)

    user <- result$user %>%
      select(username)

    dataset <- result$dataset %>%
      select(dataset_uid)

    red_result <- red_result %>%
      cbind(user) %>%
      cbind(dataset)
    return(red_result)

    } else {

      red_result <- result$results %>%
        dplyr::mutate(dataset_uid = dataset_uid) %>%
        dplyr::rename("timestamp" ="created_at") %>%
        dplyr::rename("change_uid" ="uid")


      return(red_result)

  }



}
