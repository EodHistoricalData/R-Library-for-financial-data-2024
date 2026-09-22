#' Parse api status code
#'
#' See <https://developer.mozilla.org/en-US/docs/Web/HTTP/Status> for details
#'
#' @param status_code returned status code
#'
#' @noRd
#'
#' @examples
#' parse_status_code(200)
#'
#'
parse_status_code <- function(status_code) {

  l_out <- httr::http_status(status_code)

  if (l_out$category != "Success") {
    cli::cli_abort("{l_out$message}")
  }

  return(invisible(TRUE))
}

#' TRUE when a response body carries no data
#'
#' httr gives NA_character_ for an empty body (and a zero length vector in some
#' cases), while the api answers "[]" or "{}" when nothing matched. Every caller
#' has to treat all of those as "no data", so the check lives in one place.
#'
#' @noRd
is_empty_body <- function(content) {

  if (!is.character(content) || length(content) != 1L) {
    return(TRUE)
  }

  is.na(content) || content %in% c("[]", "{}", "")

}

#' fix null values
#'
#' @noRd
fix_null <- function(x) {
  if (is.null(x)) {
    return(NA)
  } else {
    return(x)
  }

}
