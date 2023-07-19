#' Delete Field configurations
#'
#' Deletes specified field configs of dataset. If dataset_uid is the only given argument, all field configs will be deleted
#'
#' @param dataset_uid dataset_uid (default is `NULL`)
#' @param type which types of configs should be deleted (default is `NULL`)
#' @param annotation which annotation types should be deleted (default is `NULL`)
#' @param field_uid which configs for specified field should be deleted (default is `NULL`)
#' @param from_name which renaming annotations should be deleted (default is `NULL`)
#' @param fc a dataset of field configs (default is `NULL`)
#' @param processor_uid which processor_uid should be deleted (default is `NULL`)
#'
#' @export
#'
delete_field_config <- function(dataset_uid,type = NULL,annotation = NULL,field_uid = NULL,from_name = NULL, fc = NULL, processor_uid = NULL){

  if (!is.null(processor_uid)){
    to_delete <- processor_uid
  } else {
    if (is.null(fc)){
      fc <- get_field_processors(dataset_uid)
    }

    if(is.null(type) & is.null(annotation) & is.null(field_uid)) {
      # delete all
      to_delete <- fc$uid
    }
    else if(!is.null(type)) {
      if (type == "rename" & is.null(from_name)){
        to_delete <- fc$uid[which(fc$type == type & fc$from_name == from_name)]

      } else {
        to_delete <- fc$uid[which(fc$type == type)]
      }
      # delete all of type

    }
    else if(!is.null(annotation)){
      # delete all of annotation
      to_delete <- fc$uid[which(fc$annotation == annotation)]

    }
    else if(!is.null(field_uid)) {
      # delete all of field_uid
      to_delete <- fc$uid[fc$uid == field_uid]

    }
  }


  for (i in to_delete) {
    httr::DELETE(url = paste0("https://",getDomain(),"/api/",getApiType(),"/datasets/",dataset_uid,"/fields/",i,"/"),
                 query = list(apikey=getKey()),
                 httr::accept_json(),
                 httr::content_type_json())
  }
}

