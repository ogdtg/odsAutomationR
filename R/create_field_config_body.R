#' Create JSON body for adding field configs
#'
#' @param type type of field configuration
#' @param field field_id
#' @param to_name new name
#' @param type_param datatype
#' @param description description
#' @param annotation annotation type
#' @param args annotation arguments (must be a list)
#' @param change_id i TRUE the field_id will be changed
#'
#' @return a list that can be converted to a JSON body
#' @export
#'
create_field_config_body <- function(type, field = NULL,to_name = NULL,type_param = NULL,description = NULL,annotation = NULL,args = NULL, change_id = F) {
  # Rename
  if (type %in% c("rename")){
    if (!any(is.null(to_name),is.null(field))){
      if (change_id){
        body <- list(
          type = type,
          label = paste0("Rename ID",field," to ",to_name),
          from_name = field,
          to_name = to_name,
          field_label = to_name
        )
      } else {
        body <- list(
          type = type,
          label = paste0("Rename ",field," to ",to_name),
          from_name = field,
          to_name = field,
          field_label = to_name
        )
      }

      return(body)
    } else {
      stop(paste0("Missing arguments for ",type))
    }
  }

  # Change Type
  if (type %in% c("type")){
    if (!any(is.null(type_param),is.null(field))){
      body <- list(
        type = type,
        label = paste0("Setting ",field,"s type to ",type_param),
        field = field,
        type_param = type_param
      )
      return(body)
    } else {
      stop(paste0("Missing arguments for ",type))
    }
  }


  # Add description
  if (type %in% c("description")){
    if (!any(is.null(description),is.null(field))){
      body <- list(
        type = type,
        label = paste0("Describing ",field),
        field = field,
        description = description
      )
      return(body)
    } else {
      stop(paste0("Missing arguments for ",type))
    }
  }

  # Mark field as unique id
  if (type %in% c("annotate")){
    if (!any(is.null(annotation),is.null(field))){
      if (annotation %in% c("id","facet","sortable")) {
        body <- list(
          type = type,
          label = paste0("Annotation ",annotation," for ",field),
          annotation = annotation,
          field = field
        )
        return(body)
      }
      if (annotation %in% c("facetsort","timeserie_precision","unit","decimals","multivalued") & !is.null(args)) {
        body <- list(
          type = type,
          label = paste0(annotation," for ",field,": ", paste0(args,collapse = ", ")),
          field = field,
          annotation = annotation,
          args = args
        )
        return(body)
      } else {
        stop("Missing arguments for annotation ", annotation)
      }
    } else {
      stop(paste0("Missing arguments for ",type))
    }
  }

  # Order dataset fields
  if (type %in% c("order")){
    if (!any(is.null(args))){
      body <- list(
        type = type,
        label = paste0("Ordering ",paste0(args,collapse = ", ")),
        args = args
      )
      return(body)
    } else {
      stop(paste0("Missing arguments for ",type))
    }
  }

  # Delete dataset fields
  if (type %in% c("delete")){
    if (!any(is.null(field))){
      body <- list(
        type = type,
        label = paste0("Deleting ",field),
        field = field
      )
      return(body)
    } else {
      stop(paste0("Missing arguments for ",type))
    }
  }
}
