#' Sets up authentication for eodhd
#'
#' Uses the token from <https://eodhd.com/cp/dashboard> to authenticate your R session. You can find your own eodhd token from the website.
#' Alternatively, a demo token is also available for testing purposes, with a limited supply of data.
#'
#' @param token the token from eodhd. The default value is a demo token "demo", which allows for partial access to the data.
#'  See [eodhdR2::get_demo_token()] for using a demo token.
#'
#' @return Nothing
#' @export
#'
#' @examples
#' \dontrun{
#' set_token()
#' }
set_token <- function(token = get_demo_token()) {

  Sys.setenv("eodhd-token" = token)

  my_quota <- list()

  try({
    my_quota <- get_quota(token)
  })

  if (length(my_quota) == 0) {
    cli::cli_abort(
      "Unable to authenticate token at eod. Do you have the right token? Check it at {.url https://eodhd.com/cp/dashboard}"
    )
  }

  cli::cli_alert_success("eodhd API token set")
  cli::cli_alert_info("Account name: {my_quota$name} ({my_quota$email})")
  cli::cli_alert_info("Quota: {my_quota$apiRequests} | {my_quota$dailyRateLimit}")
  cli::cli_alert_info("Subscription: {my_quota$subscriptionMode}")

  if (token == get_demo_token()) {
    cat('\n')
    cli::cli_alert_danger(
      "You are using a **DEMONSTRATION** token for testing purposes, with
      limited access to the data repositories. See {.url https://eodhd.com/}
      for registration and, after finding your token, use it with
      function eodhdR2::set_token(\"TOKEN\").")
  }

  return(invisible(TRUE))

}

#' Returns token for demonstration
#'
#' @return A string with token
#' @export
#'
#' @examples
#' get_demo_token()
get_demo_token <- function() {

  token <- "demo"

  return(token)
}

get_token <- function() {

  token <- Sys.getenv("eodhd-token")

  if (token == "") {
    cli::cli_abort("Can't find eodhd token. Set your token with function eodhdR2::set_token()")
  }

  return(token)

}
