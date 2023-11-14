#' Reorder fields
#'
#' @template dataset_uid
#' @param order_vec a vevtor of field_ids in the new order
#'
#' @return processor_uid
#' @export
#'
order_fields <- function(dataset_uid,order_vec){
  body <- create_field_config_body(type = "order",annotation = "timeserie_precision",field = field, args = order_vec)
  return(update_field_processor(body=body, dataset_uid = dataset_uid))
}
