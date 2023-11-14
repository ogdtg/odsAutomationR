#' add_metadata_from_scheme
#'
#' Erstellt neuen Datensatz mit entsprechender Kennung und befüllt diesen mit Metadaten
#' Funktion kann nur auf genau definiertes Schema angewendet werden.
#' Alle Metadaten im Schema werden auf das Portal gesladen.
#'
#' @template save_local
#' @template schema
#'
#' @return dataset_uid
#' @export
#'
add_metadata_from_scheme <- function(schema,save_local = TRUE) {




  metadata_test <-readxl::read_excel(schema,sheet="Metadaten") #read schema
  #names(metadata_test)[1]<-"Metadata"
  metadata_test["Beispiel"]<-NULL

  # meta_template_df <- readRDS("meta_template_df.rds") # Metadaten Schema laden um Loop durchführen zu können

  part_id <- metadata_test$Eintrag[which(metadata_test$Metadata=="Kennung")]
  title_meta <- metadata_test$Eintrag[which(metadata_test$Metadata=="Titel")]

  metadata_cat <- get_catalog()

  #neue Kennung erzeugen
  dataset_id <- create_new_dataset_id(part_id,save_local = save_local, metadata_cat = metadata_cat)

  domain_type <- getDomain()

  # Retrieve themes
  theme_names <-metadata_test$Eintrag[grep("Thema \\d",metadata_test$Metadata)]
  theme_names <- theme_names[!is.na(theme_names)]

  if (domain_type == "int-kantonthurgau.opendatasoft.com") {
    theme_ids <- unique(themes$theme_id_int[which(themes$theme %in% theme_names)])
  } else {
    theme_ids <- themes$theme_id[which(themes$theme %in% theme_names)]

  }

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

  if (template_json$metadata$default$title$value %in% metadata_cat$title) {
    stop("Title already taken")
  }

  # Creation Date
  template_json$metadata$dcat$created$value <- Sys.time()
  template_json$metadata$default$modified$value <- Sys.time()


  # Theme
  if (length(theme_ids)==1){
    theme_ids <- list(theme_ids)
  } else if (length(theme_ids)==0){
    theme_ids <- NULL
  }
  template_json$metadata$internal$theme_id$value <- theme_ids

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
    publish_dataset(metas$uid)
    message("Dataset published.")
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
