#' Mark field as unique ID
#'
#' @template dataset_uid
#' @template field
#'
#' @return processor_uid
#' @export
#'
mark_unique_id <- function(dataset_uid,field){
  body <- create_field_config_body(type = "annotate",annotation = "id",field = field)
  return(update_field_processor(body=body, dataset_uid = dataset_uid))
}
