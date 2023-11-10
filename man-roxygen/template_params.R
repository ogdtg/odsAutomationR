#' @param dataset_uid the internal uid of the dataset. The dataset_uid can be taken from the catalog
#' @param schema path to the metadata xlsx schema
#' @param filepath path to the csv file where the actual data is stored
#' @param save_local if `TRUE`, the catalog will be saved locally
#' @param resource_uid the internal uid of a specific resource (namely a csv file or an attachment)
#' @param change_uid the internal uid of a change
#' @param encoding File encoding (for example utf-8)
#'
#' Attachments
#' @param directory Pfad zu Ordner welcher alle Anlagen enthält (Wenn nicht NULL, werden alle Inhalte des Ordners hochgeladen)
#' @param files eines oder mehrere Files die als Anlage hochgeladen werden
#'
#' Metadata
#' @param template kann metadata_catalog entnommen werden
#' @param meta_name kann metadata_catalog entnommen werden
#' @param meta_value neuer Wert
