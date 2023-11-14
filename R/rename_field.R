#' Rename field
#'
#' @template dataset_uid
#' @template field
#' @param to_name new name
#'
#' @return processor_uid
#' @export
#'
rename_field <- function(dataset_uid, field, to_name){
  body <- create_field_config_body(type = "rename",field = field, to_name = to_name)
  return(update_field_processor(body=body, dataset_uid = dataset_uid))
}
