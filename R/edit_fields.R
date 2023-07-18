#' Feldkonfigurationen hinzufügen
#'
#' @param dataset_uid dataset_uid
#' @param schema Pfad zum Excel Schema
#' @param original_names Namen aus dem `data_info.rds`. default ist `NULL`
#'
#' @export
#'
edit_fields <- function(dataset_uid, schema, original_names = NULL) {
  if (is.character(schema)) {
    spalten <- readxl::read_excel(schema, sheet = "Spaltenbeschreibungen")
    spalten <- spalten[rowSums(is.na(spalten)) != ncol(spalten), ]
  } else{
    spalten <- schema[rowSums(is.na(schema)) != ncol(schema), ]
  }

  if (is.null(original_names)) {
    original_names <- spalten$Name_Original
  }

  for (i in  seq_along(spalten$Name_Original)) {
    if (original_names[i] != spalten$Name_Original[i]) {
      rename_field(dataset_uid = dataset_uid, field = original_names[i], to_name = spalten$Name_Original[i])
    }
    add_type(dataset_uid = dataset_uid, field = original_names[i],type = spalten$type[i])
    add_description(dataset_uid = dataset_uid, field = original_names[i],description = spalten$Variablenbeschreibungen[i])

    if (!is.na(spalten$precision[i])) {
      add_timeserie_precision(dataset_uid = dataset_uid, field = original_names[i], timeserie = spalten$precision[i])
    }
    if (!is.na(spalten$kurz[i])) {
      res <- add_unit(dataset_uid = dataset_uid, field = original_names[i], unit = spalten$kurz[i])
    }
    if (spalten$type[i] == "text") {
      make_field_sortable(dataset_uid = dataset_uid, field = original_names[i])
    }
  }
}
