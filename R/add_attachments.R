#' Anlagen hinzufügen
#'
#' Mit dieser Funktion können eines oder mehere Files bzw. der Inhalt ganzer Ordner als Anlage zu einem Datensatz zugeordnet werden
#'
#' @param directory Pfad zu Ordner welcher alle Anlagen enthält (Wenn nicht NULL, werden alle Inhalte des Ordners hochgeladen)
#' @param files eines oder mehrere Files die als Anlage hochgeladen werden
#' @template dataset_uid
#' @template directory
#' @template files
#'
#' @export
#'
add_attachments <- function(directory=NULL, files=NULL, dataset_uid) {


  if (is.null(directory) && is.null(files)) {
    stop("Either files or directory must be provided")
  }
  if (!is.null(directory) && !is.null(files)) {
    stop("Files and directory will be uploaded")
    files_mod <- list.files(directory)
    files_mod <- paste0(normalizePath(directory),"/",files_mod)
    files <- c(files, files_mod)
  }
  if (is.null(files)) {
    files <- list.files(directory)
    files <- paste0(normalizePath(directory),"/",files)
  }

  files_final <- files

  for (file in files){
    if( file.exists(file)){
      exists <- TRUE
    } else {
      files_final <- files_final[files_final!=file]
      warning(paste0(file," does not exist. It will not be uploaded."))
    }
  }

  if (length(files_final)==0){
    stop("None of the files is existing. Please check the paths.")
  }

  tryCatch({
    key = getKey()
    domain = getDomain()
    api_type = getApiType()
  },
  error = function(cond) {
    stop("Not all variables initilised. Use the set functions to set variables.")

  })

  filelist <- lapply(files_final, function(x){
    body = list(
      `file` = httr::upload_file(x)
    )

    res <- httr::POST(url = paste0('https://',domain,'/api/',api_type,'/datasets/',dataset_uid,"/attachments/"), body = body, encode = 'multipart',
                      query=list(apikey=key))
    })

}

