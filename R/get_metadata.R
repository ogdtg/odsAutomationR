#' get_metadata
#'
#'Funktion um Metadaten eines bestimmten Datensatzes zu erhalten
#'
#' @param dataset_uid kann metadata_catalog entnommen werden
#'

#'
#'
#' @return Datensatz mit Metadaten eines gewünschten Datensatzes
#' @export
#'
get_metadata <- function(dataset_uid){
  tryCatch({
    key = getKey()
    domain = getDomain()
    api_type = getApiType()
  },
  error = function(cond) {
    stop("Not all variables initilised. Use the set functions to set variables.")

  })

  url = paste0('https://',domain,'/api/',api_type,'/datasets/',dataset_uid,'/metadata')



  res <- httr::GET(url = url,
                   query = list(apikey=key))


  result <- prepare_response(res)

  result <- lapply(seq_along(names(result)), function(i) {
    df  <- as.data.frame(do.call(rbind, result[[i]]))
    df$name <- row.names(df)
    row.names(df) <- 1:nrow(df)
    df$template.name <- names(result)[i]
    return(df)
  })
  result <- do.call(rbind, result)


  return(result)
}
