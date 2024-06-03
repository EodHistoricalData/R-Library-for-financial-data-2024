#' Sets up authentication for eodhd
#'
#' Uses the token from <https://eodhd.com/cp/dashboard> to authenticate your R session. You can find your own eodhd token from the website.
#' Althernatively, a demo token is also available for testing purposes.
#'
#' @param token
#'
#' @return Nothing
#' @export
#'
#' @examples
#' set_token()
set_token <- function(token = get_demo_token()) {

  Sys.setenv("eodhd-token" = token)

  my_quota <- list()

  try({
    my_quota <- get_quota(token)
  })

  if (length(my_quota) == 0) {
    cli::cli_abort(
      "Cant authenticate token at eod. Do you have the right token? Check it at <https://eodhd.com/cp/dashboard>"
    )
  }

  cli::cli_alert_success("eodhd API token set")
  cli::cli_alert_info("Account name: {my_quota$name} ({my_quota$email})")
  cli::cli_alert_info("Quota: {my_quota$apiRequests} | {my_quota$dailyRateLimit}")
  cli::cli_alert_info("Subscription: {my_quota$subscriptionMode}")

  if (token == get_demo_token()) {
    cli::cli_alert_danger(
      "You are using a DEMONSTRATION token for testing pourposes, with limited access to the data repositories.
      See <https://eodhd.com/> for registration and use function set_token(TOKEN) to set your own token.")
  }

  return(invisible(TRUE))

}

get_demo_token <- function() {
  token = "demo"
  return(token)
}

get_token <- function() {
  token <- Sys.getenv("eodhd-token")

  return(token)

}
