#' get_dataset_info
#'
#' Funktion um alle derzeit aufgeschalteten Metadaten herunterzuladen. Hier kann auch die dataset_uid entnommen werden.
#' Der Catalog wird automatisch in der Variable metadata_catalog gespeichert
#'
#' @param save_local logical ob Katalog lokal gespeichert werden soll (default ist TRUE)
#' @param dataset_uid dataset_uid wenn dataset_info von einem bestimmten dataset heruntergeladen werden soll
#'
#' @importFrom jsonlite fromJSON
#' @importFrom httr GET
#' @importFrom dplyr bind_rows
#' @importFrom dplyr select
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
  },
  error = function(cond){
    path = "Y:/SK/SKStat/Open Government Data _ OGD/Zusammenstellung Hilfsmittel OGD/Selbst erstellte Hilfsmittel/data_catalog.csv"

  })

  if (api_type == "management/v2"){
    counter = 100
    page = 0
    result = list()
    while (counter==100) {
      page = page + 1
      res <- httr::GET(url = paste0("https://",domain,"/api/",api_type,"/datasets/"),
                       query = list(rows = 100,
                                    page=page,
                                    apikey = key))
      result[[page]] <- res$content %>%
        rawToChar() %>%
        jsonlite::fromJSON() %>%
        .$datasets
      counter = nrow(result[[page]])
      if (length(counter)==0){
        break
      }
    }
  } else {
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

  }

  if(exists("metadata_catalog")){
    if (save_local){
      warning("Variable metadata_catalog will b overwritten.")
    }
    metadata_catalog <<- result %>% dplyr::bind_rows()
  } else {
    metadata_catalog <<- result %>% dplyr::bind_rows()
  }

  if (api_type == "management/v2") {
    local_df <-
      metadata_catalog %>%
      dplyr::select(dataset_uid,dataset_id) %>%
      cbind(metadata_catalog$metas$default$title) %>%
      cbind(metadata_catalog$metas$default$publisher) %>%
      cbind(metadata_catalog$metas$dcat$creator) %>%
      setNames(c("datset_uid","dataset_id","title","publisher","creator"))


  } else {
    local_df <-
      metadata_catalog %>%
      dplyr::select(dataset_uid,dataset_id) %>%
      cbind(result$metadata$default$title$value) %>%
      cbind(result$metadata$default$publisher$value) %>%
      cbind(result$metadata$dcat$creator$value) %>%
      setNames(c("datset_uid","dataset_id","title","publisher","creator"))

  }

  if (save_local) {
    tryCatch({
      write_ogd(
        local_df,
        path
      )
      message(paste0("Katalog gespeichert unter ",path))
    },
    error = function(cond){
      stop("Katalog konnte nicht gespeichert werden. Wurde der Pfad richtig initialisiert")
    })
  }

}


