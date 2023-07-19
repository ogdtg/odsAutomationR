#' create_key
#'
#' Funktion um API-Key zu erstellen, den es später für die Nutzung des Packages braucht.
#'
#' @param key_name Name des Schlüssels
#' @param username ODS-Username
#' @param password ODS-Password
#' @param domain Domain (z.b. data.tg.ch)
#' @param permissions Liste von Berechtigungen, die der Key bekommen soll. Standardmässig werden alle Berechtigungen zugeteilt
#'
#' @return API-Key
#' @export
#'
create_key <- function(key_name,api_type,username,password,domain,permissions = list("edit_dataset",
                                                                            "publish_dataset",
                                                                            "explore_restricted_dataset",
                                                                            "manage_dataset",
                                                                            "create_dataset",
                                                                            "create_page",
                                                                            "edit_domain",
                                                                            "edit_page",
                                                                            "manage_page",
                                                                            "explore_restricted_dataset",
                                                                            "edit_reuse",
                                                                            "manage_subdomains",
                                                                            "explore_monitoring",
                                                                            "edit_theme")) {

  body <- list(label = key_name,
               permissions = permissions)

  res <- httr::POST(paste0("https://",domain,"/api/",api_type,"/apikeys/"),
                    httr::authenticate(username,password),
                    body = jsonlite::toJSON(body,auto_unbox = T))

  key <- res$content %>%
    rawToChar() %>%
    jsonlite::fromJSON() %>%
    .$key

  return(key)
}
