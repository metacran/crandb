
config <- list()

.onAttach <- function(libname, pkgname) {
  ub <- unlockBinding
  ub("config", asNamespace(pkgname))
}

#' @include cran.r

appname <- (function() {
  `_appname` <- "r-crandb"
  function(name) {
    if (!missing(name)) {
      `_appname` <<- name
    }
    `_appname`
  }
})()

get_config <- function(key) {
  if (missing(key)) {
    config
  } else {
    config[[key]]
  }
}

set_config <- function(key, value) {
  config[[key]] <<- value
}

getset_config <- function(key, value, default, environment = NA) {
  if (missing(value)) {
    try_quietly(get_config(key)) %||% Sys.getenv(environment) %||% default
  } else {
    set_config(key, value)
  }
}

cran_mirror <- function(path) {
  getset_config("cran_mirror_path", path, default = cran_mirror_default)
}

couchdb_server <- function(uri, root = FALSE) {
  key <- if (root) "couchdb_server_uri_root" else "couchdb_server_uri"
  getset_config(key, uri, default = couchdb_uris)
}

couchdb_user <- function(username) {
  getset_config("couchdb_user", username, default = "",
                environment = "COUCHDB_USER")
}

couchdb_password <- function(password) {
  getset_config("couchdb_password", password, default = "",
                environment = "COUCHDB_PASSWORD")
}
