#' update_resource_with_csv
#'
#' CSV als Resource hochladen und Resource eines bestimmten Datensatzes mit dem hochgeladenen File ersetzen (DEPRECATED)
#'
#' @param filepath Pfad zum CSV File, das hochgeladen werden soll
#' @param dataset_uid dataset_uid des Datensatz, dem die Ressource zugeordnet werden soll
#' @param resource_uid resource_id of the resource that should be updated
#'
#' @export
#'
update_resource_with_csv <- function(filepath, dataset_uid, resource_uid = NULL) {

  if (is.null(resource_uid)) {
    resource_info <- get_dataset_resource(dataset_uid = dataset_uid)
    if (length(resource_info$results)==0) {
      stop("There is no resource to update")
    }

    if (length(resource_info$results$uid)>1) {
      warning("multiple resources and no resource_uid provided by user. Will update the last updated resource")
    }

    resource_uid <- resource_info$results$uid[nrow(resource_info$results)]
  }

  update_resource(dataset_uid, resource_uid=resource_uid)
}
