#' get_dataset_info
#'
#' Funktion um alle derzeit aufgeschalteten Metadaten herunterzuladen. Hier kann auch die dataset_uid entnommen werden.
#' Der Catalog wird automatisch in der Variable metadata_catalog gespeichert
#'
#' @param save_local logical ob Katalog lokal gespeichert werden soll (default ist TRUE)
#' @param dataset_uid dataset_uid wenn dataset_info von einem bestimmten dataset heruntergeladen werden soll
#'

#' @export
#'
get_dataset_info <- function(save_local = TRUE, dataset_uid = NULL) {
  tryCatch({
    key = getKey()
    domain = getDomain()
    api_type = getApiType()
  },
  error = function(cond) {
    stop("Not all variables initilised. Use the set functions to set variables.")

  })



  if (!is.null(dataset_uid)){
    res <-
      httr::GET(
        url = paste0("https://", domain, "/api/", api_type, "/datasets/",dataset_uid),
        httr::add_headers(`Content-Type` = "application/json; charset=UTF-8"),
        query = list(apikey = key)
      )
    result <- res %>%
      prepare_response()
    return(result)
  }

  tryCatch({
    path=getPath()
    path_rds <- gsub("data_catalog.csv","full_upload.rds",path)
  },
  error = function(cond){
    path = "Y:/SK/SKStat/Open Government Data _ OGD/Zusammenstellung Hilfsmittel OGD/Selbst erstellte Hilfsmittel/data_catalog.csv"
    path_rds <- "Y:/SK/SKStat/Open Government Data _ OGD/Zusammenstellung Hilfsmittel OGD/Selbst erstellte Hilfsmittel/full_catlog.rds"

  })



  limit <- get_number_of_datasets()
  res <-
    httr::GET(
      url = paste0("https://", domain, "/api/", api_type, "/datasets/"),
      httr::add_headers(`Content-Type` = "application/json; charset=UTF-8"),
      query = list(limit = limit,
                   apikey = key)
    )
  result <- res %>%
    prepare_response() %>%
    .$results
  names(result)[1] <- "dataset_uid"


  metadata_catalog <<- result


  local_df <-
    metadata_catalog[c("dataset_uid", "dataset_id")] %>%
    cbind(result$metadata$default$title$value) %>%
    cbind(result$metadata$default$publisher$value) %>%
    cbind(result$metadata$dcat$creator$value)
  names(local_df) = c("datset_uid", "dataset_id", "title", "publisher", "creator")


  if (save_local) {
    tryCatch({
      write_ogd2(
        local_df,
        path,
        fileEncoding = "utf-8"
      )
      saveRDS(metadata_catalog,file = path_rds)
    },
    error = function(cond){
      stop(paste0("Katalog konnte nicht gespeichert werden. Wurde der Pfad richtig initialisiert",cond))
    })
  }

}


