#' Retrieves splits data from eodhd
#'
#' This function will query the splits end point of eodhd and return all split information for a given stock/exchange.
#'
#' @inheritParams get_fundamentals
#'
#' @return A dataframe with split information
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # requires a subscription (paid) token
#'  df_split <- get_splits(ticker = "AAPL", exchange = "US")
#' }
get_splits <- function(ticker = "AAPL", exchange = "US",
                       cache_folder = get_default_cache(),
                       check_quota = TRUE) {

  cli::cli_h1("retrieving splits for ticker {ticker}|{exchange}")

  token <- get_token()

  if (token == get_demo_token()) {
    cli::cli_abort("You need a proper token (not demonstration) for exchange list..")
  }

  if (check_quota) {
    get_quota_status()
  }

  token <- get_token()

  f_out <- get_cache_file(ticker, exchange, cache_folder, "splits")

  if (fs::file_exists(f_out)) {

    df_split <- read_cache(f_out)

    return(df_split)
  }

  url <- glue::glue('https://eodhd.com/api/splits/{ticker}.{exchange}?api_token={token}&fmt=json')

  content <- query_api(url)

  if (content == "[]") {
    cli::cli_alert_danger("cant find split data for {ticker}|{exchange}")

    df_split <- dplyr::tibble()

  } else {
    df_split <- jsonlite::fromJSON(content) |>
      dplyr::mutate(
        ticker = ticker,
        exchange = exchange,
        .after = date
      ) |>
      dplyr::mutate(date = as.Date(date))
  }

  write_cache(df_split, f_out)

  cli::cli_alert_success("got {nrow(df_split)} rows of dividend data")

  return(df_split)

}
