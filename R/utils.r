
create_file_if_missing <- function(path, parent = TRUE) {

  if (parent) {
    dir <- dirname(path)
    if (!file.exists(dir)) { dir.create(dir, recursive = TRUE) }
  }

  if (!file.exists(path)) { cat("", file = path) }

  invisible(path)
}

extract_only <- function(list, names) {
  names <- intersect(names(list), names)
  list[names]
}

with_wd <- function(dir, expr) {
  wd <- getwd()
  on.exit(setwd(wd))
  setwd(dir)
  eval(expr, envir = parent.frame())
}

trim <- function (x) gsub("^\\s+|\\s+$", "", x)

trim_leading <- function (x)  sub("^\\s+", "", x)

trim_trailing <- function (x) sub("\\s+$", "", x)

check_external <- function(cmdline) {
  system(cmdline, ignore.stdout = TRUE, ignore.stderr = TRUE) %>%
    equals(0)
}

check_couchapp <- function() {
  if (!check_external("couchapp")) {
    stop("Need an installed couchapp")
  }
}

check_curl <- function() {
  check_external("curl --version") %||% stop("Need a working 'curl'")
}

NA_NULL <- function(x) {
  if (length(x) == 1 && is.na(x)) NULL else x
}

NULL_NA <- function(x) {
  if (is.null(x)) NA else x
}

unboxx <- function(x) {
  if (inherits(x, "scalar") ||
      is.null(x) ||
      is.list(x) ||
      length(x) != 1) x else unbox(x)
}

rsync <- function(from, to, args = "-rtlzv --delete") {
  cmd <- paste("rsync", args, from, to)
  system(cmd, ignore.stdout = TRUE, ignore.stderr = TRUE)
}

#' @importFrom spareserver spare_q

query <- function(url, error = TRUE, ...) {

  result <- url %>%
    spare_q(service = service, GET, ...) %>%
    content(as = "text", encoding = "UTF-8") %>%
    fromJSON(...)

  if (error && ("error" %in% names(result))) {
    stop("crandb query: ", result$reason, call. = FALSE)
  }

  result
}

add_class <- function(x, class_name) {
  if (! inherits(x, class_name)) {
    class(x) <- c(class_name, attr(x, "class"))
  }
  x
}

add_attr <- function(object, key, value) {
  attr(object, key) <- value
  object
}

contains <- function(x, y) y %in% x

isin <- function(x, y) x %in% y

remove_special <- function(list, level = 1) {

  assert_that(is.count(level), level >= 1)

  if (level == 1) {
    names(list) %>%
      grepl(pattern = "^_") %>%
      replace(x = list, values = NULL)
  } else {
    lapply(list, remove_special, level = level - 1)
  }

}

pluck <- function(list, idx) list[[idx]]

#' @importFrom assertthat assert_that is.string

`%+%` <- function(lhs, rhs) {
  assert_that(is.string(lhs),
              is.string(rhs))
  paste0(lhs, rhs)
}

`%s%` <- function(lhs, rhs) {
  assert_that(is.string(lhs))
  list(lhs) %>%
    c(as.list(rhs)) %>%
    do.call(what = sprintf)
}

make_id <- function(length = 8) {
  sample(c(letters, LETTERS, 0:9), length, replace = TRUE) %>%
    paste(collapse = "")
}

download_method <- function() {
  if (is.na(capabilities()["libcurl"])) "internal" else "libcurl"
}

# from https://github.com/gaborcsardi/falsy/blob/ee26873d99255560cfad60be2812cea4437d20e1/R/falsy-package.r#L209
try_quietly <- function(expr) {
  try(expr, silent = TRUE)
}

# from https://github.com/r-lib/remotes/blob/1f657ec067088add76adedfcc9a0ea2a45aac9e9/R/utils.R#L2
`%||%` <- function (a, b) if (!is.null(a)) a else b