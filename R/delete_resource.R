#' delete_resource
#'
#' Resource eines Datensatzes löschen
#'
#' @param dataset_uid dataset_uid des Datensatz, dem die Ressource zugeordnet werden soll
#' @param resource_uid resource_id of the resource that should be updated
#'
#'
#' @export
#'
delete_resource <-  function(dataset_uid, resource_uid = NULL){
  tryCatch({
    key = getKey()
    domain = getDomain()
    api_type = getApiType()
  },
  error = function(cond) {
    stop("Not all variables initilised. Use the set functions to set variables.")

  })

  if (is.null(resource_uid)) {
    resource_info <- get_dataset_resource(dataset_uid = dataset_uid)
    if (length(resource_info)==0) {
      stop("There is no resource to update")
    }

    if (length(resource_info$results$uid)>1) {
      warning("multiple resources and no resource_uid provided by user. Will update the last updated resource")
    }

    resource_uid <- resource_info$results$uid[nrow(resource_info$results)]
  }



  httr::DELETE(url = paste0("https://",domain,"/api/",api_type,"/datasets/",dataset_uid,"/resources/",resource_uid),
            query = list(apikey = key))

}