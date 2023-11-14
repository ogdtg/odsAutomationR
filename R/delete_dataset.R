#' Datensatz löschen
#'
#' Funktion um Datensatz zu löschen
#'
#' @template dataset_uid
#' @param ask wenn TRUE wird nach Bestätigung durch USer gefragt.
#'
#' @export
#'
delete_dataset <- function(dataset_uid, ask = TRUE) {
  tryCatch({
    key = getKey()
    domain = getDomain()
    api_type = getApiType()
  },
  error = function(cond) {
    stop("Not all variables initilised. Use the set functions to set variables.")

  })

  metas <- get_metadata(dataset_uid)


  if (ask) {
    response <- readline(prompt=paste0("If you want to permanently delete the dataset ",metas$value$title,", type 'yes' and press enter. \n If not, leave the line empty and press enter."))

    response <- tolower(response)
  } else if (!ask) {
    response = "ja"
  } else {
    stop("Deletion aborted")
  }



  if (response %in% c("ja","j","y","yes")) {
    tryCatch({
      httr::DELETE(url = paste0('https://',domain,'/api/',api_type,'/datasets/',dataset_uid),
                   query = list(apikey = key))
    },
    error = function(cond){
      stop("Deletion process failed")
    })
  } else {
    stop("Deletion aborted")
  }

}
