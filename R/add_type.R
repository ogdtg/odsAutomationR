#' Change the data type of a field
#'
#' @template dataset_uid
#' @template field
#' @param type type (check opendatasoft for available types)
#'
#' @return processor_uid
#' @export
#'
add_type <- function(dataset_uid,field, type){
  body <- create_field_config_body(type = "type",field = field, type_param = type)
  return(update_field_processor(body=body, dataset_uid = dataset_uid))
}
