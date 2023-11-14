#' Add a Unit
#'
#' @template dataset_uid
#' @template field
#' @param unit unit (check opendatasoft for available units)
#'
#' @return processor_uid
#' @export
#'
add_unit <- function(dataset_uid,field,unit){
  body <- create_field_config_body(type = "annotate",annotation = "unit",field = field, args = list(unit))
  return(update_field_processor(body=body, dataset_uid = dataset_uid))
}
