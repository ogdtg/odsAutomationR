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
    rawToChar() %>%
    stringr::str_replace_all(
      c(
        "Ãœ" = intToUtf8(220),
        "Ã¼" = intToUtf8(252),
        "Ã¶" = intToUtf8(246),
        "Ã¤" = intToUtf8(228),
        "Ã–" = intToUtf8(214),
        "Ã„" = intToUtf8(196)
      )
    ) %>%
    jsonlite::fromJSON()

  return(result)
}
