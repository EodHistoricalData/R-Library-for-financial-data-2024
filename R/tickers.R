#' Retrieves a list of tickers for a particular exchange
#'
#' @inheritParams get_fundamentals
#'
#' @return A dataframe with a list of tickers
#' @export
#'
#' @examples
#' \dontrun{ # requires a subscription (paid) token
#' df_tickers <- get_tickers("US")
#' }
get_tickers <- function(exchange = "US") {

  token <- get_token()
  if (token == get_demo_token()) {
    cli::cli_abort("You need a proper token (not demonstration) for the ticker list..")
  }

  cli::cli_h1("retrieving tickers for {exchange}")

  url <- glue::glue('{get_base_url()}/exchange-symbol-list/{exchange}?api_token={token}&fmt=json')

  content <- query_api(url)

  df_tickers <- jsonlite::fromJSON(content)

  cli::cli_alert_success("got {nrow(df_tickers)} rows for {exchange}")

  return(df_tickers)

}
