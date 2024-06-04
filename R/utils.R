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
