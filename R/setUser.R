#init env
user <- new.env()

# Sets the value of the variable
#' setUsername
#'
#' @param username ODS Username
#'
#' @export
#'
setUsername <- function(username) {
  assign("username", username, env=user)
}

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

# Gets the value of the variable
#' getUsername
#'
#' @return username
#' @export
#'
getUsername <- function() {
  return(get("username", user))
}

#' getKey
#'
#' @return apikey
#' @export
#'
getKey <- function() {
  return(get("apikey", user))
}

# Sets the value of the variable
#' setPassword
#'
#' @param password ODS-Passwort
#'
#' @export
#'
setPassword <- function(password) {
  assign("password", password, env=user)
}

# Gets the value of the variable
#' getPassword
#'
#' @return password
#' @export
#'
getPassword<- function() {
  return(get("password", user))
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
  return(get("ApiType", user))
}


#' setUser
#'
#'Funktion um User Daten zu setzen um package nutzen zu können
#'
#' @param username ODS-Username
#' @param password ODS-Passwort
#' @param apikey API-Key mit den benötigten Berechtigungen (default=NULL)
#' @param domain Domain des Portals (z.B. data.tg.ch)
#' @param path Pfad wo der Metadata Katalog auf lokal gespeichert werden soll
#' @param api_type automation/v1.0
#'
#' @export
#'
setUser <- function(username=NULL,password=NULL,apikey,domain,path = NULL,api_type =NULL){
  setUsername(username)
  setPassword(password)
  setKey(apikey)
  setDomain(domain)
  setApiType(api_type)
}

