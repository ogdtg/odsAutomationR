#' Rename field
#'
#' @param dataset_uid dataset_uid
#' @param field field_id
#' @param to_name new name
#'
#' @return processor_uid
#' @export
#'
rename_field <- function(dataset_uid, field, to_name){
  body <- create_field_config_body(type = "rename",field = field, to_name = to_name)
  return(update_field_processor(body=body, dataset_uid = dataset_uid))
}

#' Add a Unit
#'
#' @param dataset_uid dataset_uid
#' @param field field_id
#' @param unit unit (check opendatasoft for available units)
#'
#' @return processor_uid
#' @export
#'
add_unit <- function(dataset_uid,field,unit){
  body <- create_field_config_body(type = "annotate",annotation = "unit",field = field, args = list(unit))
  return(update_field_processor(body=body, dataset_uid = dataset_uid))
}

#' Change the field ID
#'
#' @param dataset_uid dataset_uid
#' @param field old field_id
#' @param to_name new_field_id
#'
#' @return processor_uid
#' @export
#'
change_identifier <- function(dataset_uid,field,to_name){
  body <- create_field_config_body(type = "rename",field = field, to_name = to_name,change_id = T)
  return(update_field_processor(body=body, dataset_uid = dataset_uid))
}

#' Add a description
#'
#' @param dataset_uid dataset_uid
#' @param field field_id
#' @param description description as string
#'
#' @return processor_uid
#' @export
#'
add_description <- function(dataset_uid,field,description){
  body <- create_field_config_body(type = "description",field = field, description = description)
  return(update_field_processor(body=body, dataset_uid = dataset_uid))
}

#' Mark field as unique ID
#'
#' @param dataset_uid dataset_uid
#' @param field field_id
#'
#' @return processor_uid
#' @export
#'
mark_unique_id <- function(dataset_uid,field){
  body <- create_field_config_body(type = "annotate",annotation = "id",field = field)
  return(update_field_processor(body=body, dataset_uid = dataset_uid))
}

#' Change the data type of a field
#'
#' @param dataset_uid dataset_uid
#' @param field field_id
#' @param type type (check opendatasoft for available types)
#'
#' @return processor_uid
#' @export
#'
add_type <- function(dataset_uid,field, type){
  body <- create_field_config_body(type = "type",field = field, type_param = type)
  return(update_field_processor(body=body, dataset_uid = dataset_uid))
}

#' Add timeserie precision
#'
#' @param dataset_uid dataset_uid
#' @param field field_id
#' @param timeserie timeserie (check opendatasoft for available timeseries)
#'
#' @return processor_uid
#' @export
#'
add_timeserie_precision <- function(dataset_uid,field,timeserie){
  body <- create_field_config_body(type = "annotate",annotation = "timeserie_precision",field = field, args = list(timeserie))
  return(update_field_processor(body=body, dataset_uid = dataset_uid))
}

#' Reorder fields
#'
#' @param dataset_uid dataset_uid
#' @param order_vec a vevtor of field_ids in the new order
#'
#' @return processor_uid
#' @export
#'
order_fields <- function(dataset_uid,order_vec){
  body <- create_field_config_body(type = "order",annotation = "timeserie_precision",field = field, args = order_vec)
  return(update_field_processor(body=body, dataset_uid = dataset_uid))
}

#' Make field sortable
#'
#' @param dataset_uid dataset_uid
#' @param field field_id
#'
#' @return processor_uid
#' @export
#'
make_field_sortable <- function(dataset_uid,field){
  body <- create_field_config_body(type = "annotate",annotation = "sortable",field = field)
  return(update_field_processor(body=body, dataset_uid = dataset_uid))
}
