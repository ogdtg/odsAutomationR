#' update_attachments
#'
#' Funktion um Datensatz Anhänge zu löschen und neue hochzuladen
#'
#' @param encoding File encoding
#'
#' @export
#'
update_attachments <- function(directory=NULL, files=NULL, dataset_uid) {
  delete_attachments(dataset_uid = dataset_uid)
  add_attachments(directory = directory, files = files, dataset_uid = dataset_uid)


}
