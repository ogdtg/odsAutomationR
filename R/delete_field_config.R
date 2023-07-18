
delete_field_config <- function(dataset_uid,type = NULL,annotation = NULL,field_uid = NULL,from_name = NULL, fc = NULL, processor_uid){

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

