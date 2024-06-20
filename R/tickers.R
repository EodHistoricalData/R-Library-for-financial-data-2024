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
get_tickers <- function(exchange = "US",
                        cache_folder = get_default_cache()) {

  token <- get_token()

  if (token == get_demo_token()) {
    cli::cli_abort("You need a proper token (not demonstration) for the ticker list..")
  }

  cli::cli_h1("retrieving tickers for {exchange}")

  f_out <- get_cache_file("exchange", exchange, cache_folder, "ticker-list")

  if (fs::file_exists(f_out)) {

    df_tickers <- read_cache(f_out)

  } else {

    url <- glue::glue('{get_base_url()}/exchange-symbol-list/{exchange}?api_token={token}&fmt=json')

    content <- query_api(url)

    df_tickers <- jsonlite::fromJSON(content)

    write_cache(df_tickers, f_out)

  }

  cli::cli_alert_success("got {nrow(df_tickers)} rows for {exchange}")

  return(df_tickers)

}
