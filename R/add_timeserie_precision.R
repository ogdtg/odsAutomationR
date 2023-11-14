#' Add timeserie precision
#'
#' @template dataset_uid
#' @template field
#' @param timeserie timeserie (check opendatasoft for available timeseries)
#'
#' @return processor_uid
#' @export
#'
add_timeserie_precision <- function(dataset_uid,field,timeserie){
  body <- create_field_config_body(type = "annotate",annotation = "timeserie_precision",field = field, args = list(timeserie))
  return(update_field_processor(body=body, dataset_uid = dataset_uid))
}
