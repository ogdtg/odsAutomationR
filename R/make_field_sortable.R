#' Make field sortable
#'
#' @template dataset_uid
#' @template field
#'
#' @return processor_uid
#' @export
#'
make_field_sortable <- function(dataset_uid,field){
  body <- create_field_config_body(type = "annotate",annotation = "sortable",field = field)
  return(update_field_processor(body=body, dataset_uid = dataset_uid))
}
