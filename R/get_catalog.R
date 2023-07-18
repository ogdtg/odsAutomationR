#' Get detailed Meta Data
#'
#' @param key API key from OpenDataSoft
#' @description Function to retrieve meta data from the backend. This function is for internal use only. An API key must be specified and passed to the function.
#' @return dataframe containing the meta data.
#'
#' @importFrom attempt stop_if_not
#' @importFrom glue glue
#' @importFrom jsonlite fromJSON
#' @importFrom httr GET
#' @importFrom httr status_code
#' @export
#'
#'
get_catalog = function(){
  tryCatch({
    key = getKey()
    domain = getDomain()
    api_type = getApiType()
  },
  error = function(cond) {
    stop("Not all variables initilised. Use the set functions to set variables.")

  })
  link = glue::glue("https://data.tg.ch/explore/dataset/ods-datasets-monitoring/download/?format=json&disjunctive.dataset_id=true&timezone=Europe/Berlin&lang=de&source=monitoring&apikey={key}")

  res = httr::GET(link)

  result=jsonlite::fromJSON(rawToChar(res$content), flatten = TRUE)
  return(result)


}
