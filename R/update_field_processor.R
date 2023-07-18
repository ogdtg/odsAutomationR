#' Update Field Processor
#'
#' Updates or appends a new field configuration
#'
#' @param dataset_uid dataset_uid
#' @param body body in list and NOT in json format
#'
#' @export
#'
update_field_processor <- function(dataset_uid, body){
  fc <- get_field_processors(dataset_uid)


  if (body$type == "rename"){
    processor_uid <- fc$uid[which(fc$type==body$type & fc$annotation ==body$annotation & fc$from_name == body$from_name)]


  } else if (body$type == "annotate") {
    processor_uid <- fc$uid[which(fc$type==body$type & fc$annotation ==body$annotation & fc$field == body$field)]

  } else if(body$type %in% c("description","type")) {
    processor_uid <- fc$uid[which(fc$type==body$type & fc$field == body$field)]

  } else if(body$type == "order") {
    processor_uid <- fc$uid[which(fc$type==body$type)]

  }


  if (length(processor_uid)>0) {
    # update
    res <- add_field_config(body=jsonlite::toJSON(body, auto_unbox = T), dataset_id = dataset_uid, update = T, field_uid = processor_uid[1])
  } else {
    # add
    res <- add_field_config(body=jsonlite::toJSON(body, auto_unbox = T), dataset_id = dataset_uid)
  }
  return(res)
}
