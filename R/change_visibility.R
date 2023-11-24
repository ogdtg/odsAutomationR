#' Change visibility of a dataset
#'
#' @description Restricts the visibility of a dataset. If restrict is set to `TRUE`, only logged in user with appropriate permissions can see the dataset.
#'
#' @template dataset_uid
#' @param restrict if `TRUE`, the dataset will not be visible for everyone anymore. If `FALSE`, restrictions on visibility are lifted.
#'
#' @export
#'
change_visibility <- function(dataset_uid, restrict){

  tryCatch({
    key = getKey()
    domain = getDomain()
    api_type = getApiType()
  }, error = function(cond) {
    stop("Not all variables initilised. Use the set functions to set variables.")
  })


  dataset_meta <- list(dataset_uid = dataset_uid,
                       is_restricted = restrict,
                       metadata = get_metadata(dataset_uid = dataset_uid, as_list = TRUE))

  url = paste0("https://", domain, "/api/", api_type, "/datasets/",
               dataset_uid)

  res <- httr::PUT(url = url, query = list(apikey = key),
                    httr::accept_json(),
                    httr::content_type_json(),
                    body = jsonlite::toJSON(dataset_meta,auto_unbox = T))

  if (res$status_code != 200){
    stop(content(res)$message)
  }

  publish_dataset(dataset_uid)


}


