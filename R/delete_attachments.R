#' delete_attachments
#'
#' Funktion um Datensatz Anhänge zu löschen
#'
#' @template dataset_uid
#'
#' @export
#'
delete_attachments <- function(dataset_uid) {
  tryCatch({
    key = getKey()
    domain = getDomain()
    api_type = getApiType()
  },
  error = function(cond) {
    stop("Not all variables initilised. Use the set functions to set variables.")

  })
  df <- get_dataset_attachments(dataset_uid = dataset_uid)
  if (length(df)>0){
    invisible(lapply(df$uid,function(x){
      res <- httr::DELETE(url = paste0('https://',domain,'/api/',api_type,'/datasets/',dataset_uid,"/attachments/", x),
                          query = list(apikey = key))
    }))
  }

}
