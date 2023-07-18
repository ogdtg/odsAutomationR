#' write_ogd2
#'
#' Funktion um Datensatz mit korrekten OGD Spezifikationen als csv zu speichern.
#' UTF-8 wird nicht explizit definiert, da dies manchmal zu Problemen beim Upload auf ODS führt (bei Umlauten)
#'
#' @param data R Dataframe
#' @param file Pfad zum Speicherort (muss mit .csv enden)
#' @param ... see `write.table()`
#'
#' @export
#'
write_ogd2 <- function(data,file,...){
  write.table( #Write Table als basis funktion von write.csv, da Spezifikationen hier möglich sind
    data,
    file = file,
    quote = T, #Anfuehrungszeichen um Strings und Factors
    sep = ",", # Komma als Trennzeichen
    dec = ".", # Punkt als Dezimaltrenner
    row.names = F, #Keine Reihennamen
    ...
  )
  message("Datensatz gespeichert als csv.")
}
