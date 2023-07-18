#' Bestehenden Datensatz bearbeiten (Metadaten und Feldkonfigs)
#'
#' @param dataset_uid dataset_uid
#' @param filepath Pfad zum Excel Schema
#'
#' @export
#'
update_metadata_and_fields <- function(dataset_uid,filepath){


  tryCatch({
    key = getKey()
    domain = getDomain()
    api_type = getApiType()
  },
  error = function(cond) {
    stop("Not all variables initilised. Use the set functions to set variables.")

  })

  # Catalog to compare title with existing title
  metadata_cat <- get_catalog()

  # Metadata of the dataset to compare and retrieve dataset_id
  single_meta <- get_catalog(dataset_uid = dataset_uid)


  metadata_test <- readxl::read_excel(filepath,sheet="Metadaten") #read schema

  ## METADATA
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
  template_json$dataset_id <- single_meta$dataset_id

  # Title
  template_json$metadata$default$title$value <- metadata_test$Eintrag[which(metadata_test$Metadata=="Titel")]

  if (template_json$metadata$default$title$value %in% metadata_cat$title){
    index <- which(metadata_cat$title==template_json$metadata$default$title$value)

    if (dataset_uid != metadata_cat$dataset_uid[index] ){
      stop("Title already taken")
    }
  }

  # Creation Date
  template_json$metadata$dcat$created$value <- Sys.time()
  template_json$metadata$default$modified$value <- Sys.time()


  # Theme
  template_json$metadata$internal$theme_id$value <- list(theme_ids)

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
  template_json$metadata$default$publisher$value <- paste0(metadata_test$Eintrag[which(metadata_test$Metadata=="Amt")], " Kanton Thurgau")
  template_json$metadata$dcat$creator$value <- template_json$metadata$default$publisher$value

  # Accrual Periodicity
  accrualper<- metadata_test$Eintrag[which(metadata_test$Metadata=="Aktualisierungsintervall")]

  if(!is.na(accrualper)){
    template_json$metadata$dcat$accrualperiodicity$value <- metadata_test$Eintrag[which(metadata_test$Metadata=="Aktualisierungsintervall")]
  }

  # Reference
  if (!is.na(metadata_test$Eintrag[which(metadata_test$Metadata=="Referenz")])){
    template_json$metadata$default$references$value <- metadata_test$Eintrag[which(metadata_test$Metadata=="Referenz")]
  }

  # Attributions
  template_json$metadata$default$attributions$value <- attributions


  # Perform API reguest
  res <- httr::PUT(url = paste0('https://',getDomain(),'/api/',getApiType(),'/datasets/',dataset_uid,"/metadata/"),
                    query = list(apikey=getKey()),
                    body = jsonlite::toJSON( template_json$metadata, auto_unbox = T),
                    httr::accept_json(),
                    httr::content_type_json())


  metas <- res$content %>% rawToChar() %>% jsonlite::fromJSON()


  ## SPALTEN

  # Delete all units
  fc <- get_field_processors(dataset_uid = dataset_uid, limit = 1000)
  to_delete <- which(fc$annotation=="unit")
  if (length(to_delete)>0){
    delete_field_config(dataset_uid = dataset_uid, processor_uid = fc$uid[to_delete])
  }

  # Edit fields
  edit_fields(dataset_uid = dataset_uid, schema = filepath)
}
