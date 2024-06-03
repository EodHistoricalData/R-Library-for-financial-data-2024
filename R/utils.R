#' Parse api status code
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

  if (status_code == 200) {

    # this is ok

  } else  if (status_code == 400) {

    cli::cli_abort("got a 400 (missing parameter) return code from API (check inputs?)")

  } else if (status_code == 403) {

    cli::cli_abort("got a 403 (forbidden) return code from API (check your token & subscription?)")

  } else {

    cli::cli_abort("error on server side.. ")

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
