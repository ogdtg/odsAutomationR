#' Get Number of Datasets
#'
#' Retrieves the number of all datasets on ODS (including unpublished ones)
#' Works only correctly with Automation API.
#'
#' @return number of datasets on ODS
#' @export
#'
get_number_of_datasets <- function(){
  tryCatch({
    key = getKey()
    domain = getDomain()
    api_type = getApiType()
  },
  error = function(cond) {
    stop("Not all variables initilised. Use the set functions to set variables.")
  })

  if (api_type == "automation/v1.0") {
    res <-
      httr::GET(
        url = paste0("https://", domain, "/api/", api_type, "/datasets/"),
        httr::add_headers(`Content-Type` = "application/json; charset=UTF-8"),
        query = list(limit = 0,
                     apikey = key)
      )
    result <- res %>%
      prepare_response() %>%
      .$total_count
    return(result)
  } else {
    get_dataset_info(save_local = F)
    return(nrow(metadata_catalog))
  }
}
