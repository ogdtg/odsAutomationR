#' Add a description
#'
#' @template dataset_uid
#' @template field
#' @param description description as string
#'
#' @return processor_uid
#' @export
#'
add_description <- function(dataset_uid,field,description){
  body <- create_field_config_body(type = "description",field = field, description = description)
  return(update_field_processor(body=body, dataset_uid = dataset_uid))
}

