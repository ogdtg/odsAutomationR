#' Delete and reupload resource
#'
#' @param dataset_uid dataset_uid des Datensatz, dem die Ressource zugeordnet werden soll
#' @param resource_uid resource_id of the resource that should be updated
#' @param filepath Pfad zum CSV File
#' @param encoding File encoding
#'
#' @export
#'
reupload_resource <- function(dataset_uid, resource_uid = NULL,filepath, encoding){

  if (is.null(resource_uid)) {
    resource_info <- get_dataset_resource(dataset_uid = dataset_uid)
    if (length(resource_info$results)==0) {
      message("There is no resource to update. Will add new resource")
      resource_uid <- add_file_to_dataset(filepath = filepath, dataset_uid = dataset_uid, encoding = encoding)
      return(resource_uid)
    }

    if (length(resource_info$results$uid)>1) {
      warning("multiple resources and no resource_uid provided by user. Will update the last updated resource")
    }

    resource_uid <- resource_info$results$uid[nrow(resource_info$results)]
  }

  delete_resource(resource_uid)
  resource_uid <- add_file_to_dataset(filepath = filepath, dataset_uid = dataset_uid, encoding = encoding)
  return(resource_uid)
}
