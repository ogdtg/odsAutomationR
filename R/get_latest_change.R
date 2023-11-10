#' get_latest_change
#'
#' Neueste change_uid
#'
#' @template template_params
#'
#' @return change_uid
#' @export
#'
get_latest_change <- function(dataset_uid) {
  changes <- get_dataset_changes(dataset_uid)
  if (length(df)>0){
    return(changes$change_uid[nrow(changes)])
  } else {
    return(NULL)
  }
}

