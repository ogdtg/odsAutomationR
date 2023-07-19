#init env
user <- new.env()


# Sets the value of the variable
#' setKey
#'
#' @param apikey API-Key mit den benötigten Berechtigungen
#'
#' @export
#'
setKey <- function(apikey) {
  assign("apikey", apikey, env=user)
}


#' getKey
#'
#' @return apikey
#' @export
#'
getKey <- function() {
  env_var <- Sys.getenv("ODS_KEY")
  if(env_var!=""){
    return(env_var)
  }
  return(get("apikey", user))
}


#' setDomain
#'
#' @param domain Domain des Portals (z.B. data.tg.ch)
#'
#' @export
#'
setDomain <- function(domain) {
  domain <- gsub("https://","",domain)
  domain <- gsub("http://","",domain)
  domain <- gsub("http:/","",domain)
  assign("domain", domain, env=user)
}

#' getDomain
#'
#' @return domain
#' @export
#'
getDomain<- function() {
  env_var <- Sys.getenv("ODS_DOMAIN")
  if(env_var!=""){
    return(env_var)
  }
  return(get("domain", user))
}

#' setPath
#'
#' @param path Pfad wo der Metadata Katalog auf lokal gespeichert werden soll
#'
#' @export
#'
setPath <- function(path) {
  assign("path", path, env=user)
}

#' getPath
#'
#' @return path
#' @export
#'
getPath<- function() {
  env_var <- Sys.getenv("ODS_PATH")
  if(env_var!=""){
    return(env_var)
  }
  return(get("path", user))
}


#' setApiType
#'
#' @param api_type automation/v1.0
#'
#' @export
#'
setApiType <- function(api_type) {
  assign("ApiType", api_type, env=user)
}

#' getApiType
#'
#' @return api_type
#' @export
#'
getApiType <- function() {
  env_var <- Sys.getenv("ODS_APITYPE")
  if(env_var!=""){
    return(env_var)
  }
  return(get("ApiType", user))
}


