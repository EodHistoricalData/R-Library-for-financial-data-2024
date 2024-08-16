#' Retrieves adjusted and unadjusted stock prices
#'
#' This function will query the price end point of eodhd and return daily stock price from a set of ticker and exchange.
#' It also includes the daily stock return (percentage variation).
#'
#' @inheritParams get_fundamentals
#'
#' @return A dataframe with prices
#' @export
#'
#' @examples
#' \dontrun{
#' set_token(get_demo_token())
#' df_prices <- get_prices(ticker = "AAPL", exchange = "US")
#' }
get_prices <- function(ticker = "AAPL",
                       exchange = "US",
                       cache_folder = get_default_cache(),
                       check_quota = TRUE) {

  cli::cli_h1("retrieving price data for ticker {ticker}|{exchange}")

  if (check_quota) {
    get_quota_status()
  }

  token <- get_token()

  f_out <-get_cache_file(ticker, exchange, cache_folder, "prices")

  if (fs::file_exists(f_out)) {

    df_out <- read_cache(f_out)

    return(df_out)
  }

  url <- glue::glue('{get_base_url()}/eod/{ticker}.{exchange}?api_token={token}&fmt=json')

  content <- query_api(url)

  df_prices <- jsonlite::fromJSON(content) |>
    dplyr::mutate(
      ticker = ticker,
      exchange = exchange
    ) |>
    dplyr::mutate(date = as.Date(date),
                  ret_adj_close = adjusted_close/dplyr::lag(adjusted_close) - 1)

  write_cache(df_prices, f_out)

  cli::cli_alert_success("got {nrow(df_prices)} rows of prices")
  cli::cli_alert_info("got daily data from {min(df_prices$date)} to {max(df_prices$date)}")

  return(df_prices)

}
