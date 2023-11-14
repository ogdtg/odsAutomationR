#' Create a ODS Dataset
#'
#' Takes a data.frame and a metadata schema and creates a complete dataset on ODS
#'
#' @param data R Dataframe
#' @template schema
#' @template filepath
#' @param attachments one or several files or a directory (see `add_attachments`)
#'
#' @export
#'
#' @return dataset_uid
#'
#'
create_ogd <- function(data,schema,filepath,attachments = NULL){

  file_dir <- sub("/[^/]*$", "", filepath)
  if (!dir.exists(file_dir)) {
    stop(paste0(filepath, " does not exist."))
  }
  if (!file.exists(schema)) {
    stop(paste0(schema, " does not exist."))
  }

  # save data as csv
  write_ogd2(data=data,file =filepath, fileEncoding = "utf-8", na = "")
  # add metadata
  dataset_uid <- add_metadata_from_scheme(schema = schema, save_local = F)
  # add data
  resource_uid <- update_resource(dataset_uid = dataset_uid, filepath = filepath, encoding = "utf-8")
  # edit fields
  edit_fields(dataset_uid = dataset_uid,schema = schema)
  # add attachments
  if (!is.null(attachments)){
    if (dir.exists(attachments[1])){
      add_attachments(dataset_uid = dataset_uid, directory = attachments)
    } else {
      add_attachments(dataset_uid = dataset_uid, files = attachments)
    }
  }
  # publish dataset
  publish_dataset(dataset_uid=dataset_uid)

  return(dataset_uid)


}
