#' Retriees the list of exchanges available
#'
#' @return a dataframe with information about available exchanges
#' @export
#'
#' @examples
#'
#' # you need a valid token (not test) for this to work
#' \dontrun{
#' set_token(YOUR_VALID_TOKEN)
#' df_exc <- get_exchanges()
#' }
#'
get_exchanges <- function() {

  cli::cli_h1("fetching exchange list")

  token <- get_token()
  if (token == get_demo_token()) {
    cli::cli_abort("You need a proper token (not \"{get_demo_token()}\") for retrieving the list of exchanges.")
  }

  url <- glue::glue(
    '{get_base_url()}/exchanges-list/?api_token={token}&fmt=json'
  )

  content <- query_api(url)

  df_exc <- jsonlite::fromJSON(content)

  cli::cli_alert_success("got {nrow(df_exc)} rows")

  return(df_exc)
}
