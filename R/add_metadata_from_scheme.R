#' add_metadata_from_scheme
#'
#' Erstellt neuen Datensatz mit entsprechender Kennung und befüllt diesen mit Metadaten
#' Funktion kann nur auf genau definiertes Schema angewendet werden.
#' Alle Metadaten im Schema werden auf das Portal gesladen.
#'
#' @param filepath Pfad zum ausgefüllten Schema
#' @param save_local siehe get_dataset_info
#'
#' @return dataset_uid
#' @export
#'
add_metadata_from_scheme <- function(filepath,save_local = TRUE) {




  metadata_test <- readxl::read_excel(filepath,sheet="Metadaten") #read schema
  #names(metadata_test)[1]<-"Metadata"
  metadata_test["Beispiel"]<-NULL

  # meta_template_df <- readRDS("meta_template_df.rds") # Metadaten Schema laden um Loop durchführen zu können

  part_id <- metadata_test$Eintrag[which(metadata_test$Metadata=="Kennung")]
  title_meta <- metadata_test$Eintrag[which(metadata_test$Metadata=="Titel")]

  metadata_cat <- get_catalog()

  #neue Kennung erzeugen
  dataset_id <- create_new_dataset_id(part_id,save_local = save_local, metadata_cat = metadata_cat)

  api_type <- getApiType()


  # Retrieve themes
  theme_names <-metadata_test$Eintrag[grep(metadata_test$Metadata, "Thema \\d")]
  theme_names <- theme_names[!is.na(theme_names)]
  theme_ids <- themes$theme_id[which(themes$theme == theme_names)]

  # Retrieve Keywords
  keywords <-
    metadata_test$Eintrag[which(metadata_test$Metadata == "Schluesselwoerter")]
  keywords <- strsplit(keywords, ",")

  # Retrieve Attributions
  attributions <-
    metadata_test$Eintrag[which(metadata_test$Metadata == "Zuschreibungen")]
  attributions <- strsplit(attributions, ",")

  # Dataset ID
  template_json$dataset_id <- dataset_id

  # Title
  template_json$metadata$default$title$value <-
    metadata_test$Eintrag[which(metadata_test$Metadata == "Titel")]

  if (template_json$metadata$default$title$value %in% metadata_cat$fields.title) {
    stop("Title already taken")
  }

  # Creation Date
  template_json$metadata$dcat$created$value <- Sys.time()
  template_json$metadata$default$modified$value <- Sys.time()


  # Theme
  template_json$metadata$internal$theme_id$value <-
    list(theme_ids)

  # Keywords
  template_json$metadata$default$keyword$value <- keywords[[1]]

  # Description
  desc <- gsub("\r\n+","</p><p>",metadata_test$Eintrag[which(metadata_test$Metadata == "Beschreibung")])

  template_json$metadata$default$description$value <- paste0(
    "<p>",
    desc,
    "</p>",
    "<p></p><p>Datenquelle: ",
    metadata_test$Eintrag[which(metadata_test$Metadata == "Amt")],
    " Kanton Thurgau</p>"

  )


  # Language
  template_json$metadata$default$language$value <- "de"

  # Publisher and Creator
  template_json$metadata$default$publisher$value <-
    paste0(metadata_test$Eintrag[which(metadata_test$Metadata == "Amt")], " Kanton Thurgau")
  template_json$metadata$dcat$creator$value <-
    template_json$metadata$default$publisher$value

  # Accrual Periodicity
  accrualper <-
    metadata_test$Eintrag[which(metadata_test$Metadata == "Aktualisierungsintervall")]

  if (!is.na(accrualper)) {
    template_json$metadata$dcat$accrualperiodicity$value <-
      metadata_test$Eintrag[which(metadata_test$Metadata == "Aktualisierungsintervall")]
  }

  # Reference
  if (!is.na(metadata_test$Eintrag[which(metadata_test$Metadata == "Referenz")])) {
    template_json$metadata$default$references$value <-
      metadata_test$Eintrag[which(metadata_test$Metadata == "Referenz")]
  }

  # Attributions
  template_json$metadata$default$attributions$value <-
    attributions


  # Perform API reguest
  res <-
    httr::POST(
      url = paste0('https://', getDomain(), '/api/', getApiType(), '/datasets/'),
      query = list(apikey = getKey()),
      body = jsonlite::toJSON(template_json, auto_unbox = T),
      httr::accept_json(),
      httr::content_type_json()
    )


  metas <- res$content %>% rawToChar() %>% jsonlite::fromJSON()
  if (res$status_code == 201) {
    return(metas$uid)
  } else {
    warning(paste0(
      "API returned Status Code:",
      res$status_code,
      " ",
      metas$message
    ))
    return(NULL)
  }
}
