#' Retrieves dividend data from the api
#'
#' This function will query the dividend end point
#' <https://eodhd.com/financial-apis/api-splits-dividends> and return:
#' * dates (declaration, record, payment)
#' * value of dividend (adjusted and unajusted)
#' * currency of dividend
#'
#' @inheritParams get_fundamentals
#'
#' @return A dataframe with dividend information
#'
#' @export
#'
#' @examples
#' \dontrun{
#' set_token(get_demo_token())
#' df_div <- get_dividends(ticker = "AAPL", exchange = "US")
#' df_div
#' }
get_dividends <- function(ticker = "AAPL", exchange = "US",
                          cache_folder = get_default_cache(),
                          check_quota = TRUE) {

  cli::cli_h1("retrieving dividends for ticker {ticker}|{exchange}")

  if (check_quota) {
    get_quota_status()
  }

  token <- get_token()

  f_out <-get_cache_file(ticker, exchange, cache_folder, "dividends")

  if (fs::file_exists(f_out)) {

    df_div <- read_cache(f_out)

  } else {
    url <- glue::glue(
      'https://eodhd.com/api/div/{ticker}.{exchange}?api_token={token}&fmt=json'
      )

    content <- query_api(url)

    if (content == "[]") {
      cli::cli_alert_danger("cant find dividend data for {ticker}|{exchange}")

      df_div <- dplyr::tibble()

    } else {
      df_div <- jsonlite::fromJSON(content) |>
        dplyr::mutate(
          ticker = ticker,
          exchange = exchange,
          .after = date
        ) |>
        dplyr::mutate(date = as.Date(date))
    }

    write_cache(df_div, f_out)
  }

  cli::cli_alert_success("got {nrow(df_div)} rows of dividend data")

  return(df_div)

}
