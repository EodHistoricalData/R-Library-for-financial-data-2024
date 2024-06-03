#' Fetches dividend data from eodhd
#'
#' @inheritParams get_fundamentals
#'
#' @return A dataframe with dividend information
#'
#' @export
#'
#' @examples
#' \dontrun{
#'  df_div <- get_dividends(ticker = "AAPL", exchange = "US")
#' }
get_dividends <- function(ticker = "AAPL", exchange = "US",
                          cache_folder = get_default_cache(),
                          check_quota = TRUE) {

  cli::cli_alert_info("fetching dividends for ticker {ticker}|{exchange}")

  if (check_quota) {
    get_quota_status()
  }

  token <- get_token()

  f_out <-get_cache_file(ticker, exchange, cache_folder, "dividends")

  if (fs::file_exists(f_out)) {
    cli::cli_alert_success("\tfile {f_out} already exists..")

    df_div <- read_cache(f_out)

    return(df_div)
  }

  url <- glue::glue('https://eodhd.com/api/div/{ticker}.{exchange}?api_token={token}&fmt=json')

  content <- query_api(url)

  if (content == "[]") {
    cli::cli_alert_danger("\tcant find dividend data for {ticker}|{exchange}")

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

  cli::cli_alert_success("\tgot {nrow(df_div)} rows of dividend data")


  return(df_div)

}
