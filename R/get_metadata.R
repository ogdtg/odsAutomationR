#' get_metadata
#'
#'Funktion um Metadaten eines bestimmten Datensatzes zu erhalten
#'
#' @template dataset_uid
#' @param as_list if `TRUE` the function will return the original JSON as list instead of as data.frame (default is `FALSE`)
#'
#' @return Datensatz mit Metadaten eines gewünschten Datensatzes
#' @export
#'
get_metadata <- function(dataset_uid, as_list = FALSE){
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
  if (as_list){
    return(result)
  }

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
