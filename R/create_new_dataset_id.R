#' create_new_dataset_id
#'
#' Funktion erzeugt Kennung mit durchgängiger Nummerierung ohne Duplikate
#'
#' @param test_id String in Form Departement-Amt (Beispiel: sk-stat)
#' @param save_local see `get_dataset_info()`
#' @param metadata_cat Metadaten Katalog (default ist `NULL`)
#'
#' @return dataset_id/technische Kennung
#' @export
#'
create_new_dataset_id = function(test_id,save_local = TRUE, metadata_cat = NULL){

  if (is.null(metadata_cat)){
    metadata_cat <- get_catalog()
  }

  id_mod = gsub("-\\d+","",test_id)
  id_vec = metadata_cat$fields.dataset_id[grep(id_mod,metadata_cat$fields.dataset_id)]
  if (length(id_vec)==0){
    new_id = paste0(test_id,"-1")
    return(new_id)
  } else {
    new_id = gsub(paste0(id_mod, "-"), "", id_vec) %>%
      as.numeric() %>%
      max() %>%
      +1 %>%
      paste0(id_mod,"-",.)
    return(new_id)
  }
}
