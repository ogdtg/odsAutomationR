#' Prepare API Response
#'
#' Prepares JSON and converts Umlaute correctly
#'
#' @param res API response
#'
#' @return data.frame or  list from json
#' @export
#'
prepare_response <- function(res) {
  result <- res$content %>%
    rawToChar()

  for (i in seq_along(char_vec)) {
    result <- gsub(char_vec[i], replace_vec[i], result, fixed = TRUE)
  }

  result <- jsonlite::fromJSON(result)

  return(result)
}
