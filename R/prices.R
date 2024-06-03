#' Fetches adjusted and unadjusted stock prices prices
#'
#' @inheritParams get_fundamentals
#'
#' @return
#' @export
#'
#' @examples
#' set_token("demo")
#' df_prices <- get_prices(ticker = "AAPL", exchange = "US")
get_prices <- function(ticker = "AAPL",
                       exchange = "US",
                       cache_folder = fs::path_temp("oedhd-cache"),
                       check_quota = TRUE) {


  token <- get_token()
  my_quota <- get_quota(token)

  # quota refreshes at 00:00:00 GMT
  default_tz <- "GMT"
  time_refresh <- lubridate::ymd_hms(paste0(Sys.Date()+1, " 00:00:00"),
                                     tz = default_tz)
  hours_to_renew <- - as.numeric(
    lubridate::now(default_tz) - time_refresh
  )

  cli::cli_h1("fetching eod prices for ticker {ticker}|{exchange}")
  cli::cli_alert_warning('Quota status: {my_quota$apiRequests}|{my_quota$dailyRateLimit}, refreshing in {format(hours_to_renew, digits =3)} hours')

  if (my_quota$apiRequests + 10 >= my_quota$dailyRateLimit) {
    cli::cli_abort("ABORT: reached max number of daily requests -- {my_quota$apiRequests}/{my_quota$dailyRateLimit} -- need to wait for refresh")
  }

  f_out <- fs::path(
    cache_folder,
    glue::glue("{ticker}_{exchange}_eod-prices.rds")
  )

  fs::dir_create(dirname(f_out), recurse = TRUE)

  if (fs::file_exists(f_out)) {
    cli::cli_alert_success("\treading cache file {f_out}")

    df_out <- readr::read_rds(f_out)

    return(df_out)
  }

  url <- glue::glue('https://eodhd.com/api/eod/{ticker}.{exchange}?api_token={token}&fmt=json')

  content <- query_api(url)

  df_prices <- jsonlite::fromJSON(content) |>
    dplyr::mutate(
      ticker = ticker,
      exchange = exchange
    ) |>
    dplyr::mutate(date = as.Date(date))

  readr::write_rds(df_prices, f_out)

  cli::cli_alert_success("\tgot {nrow(df_prices)} rows of prices")
  cli::cli_alert_info("\tgot daily data from {min(df_prices$date)} to {max(df_prices$date)}")

  return(df_prices)

}
