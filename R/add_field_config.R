#' add_field_config
#'
#' Funktiion führt POST request mit erzrugtem JSON Body durch
#'
#' @param body JSON File erzeugt durch create_fields_body
#' @param dataset_id kann metadata_catalog entnommen werden
#' @param update if `TRUE` specific processor will be updated
#' @param field_uid processor_uid (default is `NULL`)
#'
#' @importFrom httr authenticate
#' @importFrom httr POST
#'
#'
add_field_config <- function(body, dataset_id, update = F, field_uid = NULL){
  tryCatch({
    key = getKey()
    domain=getDomain()
    api_type = getApiType()
  },
  error = function(cond){
    stop("Not all variables initilised. Use the set functions to set variables.")

  })

    if (update){
      res <- httr::PUT(url = paste0("https://",domain,"/api/",api_type,"/datasets/",dataset_id,"/fields/",field_uid,"/"),
                        body = body,
                        query = list(apikey=key),
                        httr::accept_json(),
                        httr::content_type_json())
      result <- res$content %>% rawToChar() %>% jsonlite::fromJSON()
      return(result)

    } else {

      res <- httr::POST(url = paste0("https://",domain,"/api/",api_type,"/datasets/",dataset_id,"/fields/"),
                        body = body,
                        query = list(apikey=key),
                        httr::accept_json(),
                        httr::content_type_json())
      result <- res$content %>% rawToChar() %>% jsonlite::fromJSON()
      return(result)
    }
}


