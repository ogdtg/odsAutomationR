#' Change the field ID
#'
#' @template dataset_uid
#' @template field
#' @param to_name new_field_id
#'
#' @return processor_uid
#' @export
#'
change_identifier <- function(dataset_uid,field,to_name){
  body <- create_field_config_body(type = "rename",field = field, to_name = to_name,change_id = T)
  return(update_field_processor(body=body, dataset_uid = dataset_uid))
}
