#' Retrieves delayed real time (live) quotes
#'
#' Queries the live/delayed endpoint
#' <https://eodhd.com/financial-apis/live-ohlcv-stocks-api> for one or more
#' tickers. The delay depends on the exchange and on your subscription. Live data
#' is never cached.
#'
#' @inheritParams get_fundamentals
#' @param extra_tickers an optional character vector of additional tickers, with
#'  exchange included (e.g. c("TSLA.US", "VTI.US")). The api allows up to 15
#'  extra tickers per call.
#'
#' @return A dataframe with one row per ticker
#' @export
#'
#' @examples
#' \dontrun{
#' set_token(get_demo_token())
#' df_live <- get_real_time(ticker = "AAPL", exchange = "US")
#' }
get_real_time <- function(ticker = "AAPL",
                          exchange = "US",
                          extra_tickers = NULL,
                          check_quota = TRUE) {

  cli::cli_h1("retrieving live quote for {ticker}|{exchange}")

  if (check_quota) {
    get_quota_status()
  }

  params <- list()

  if (!is.null(extra_tickers)) {
    params[["s"]] <- paste0(extra_tickers, collapse = ",")
  }

  content <- eodhd_content(glue::glue("real-time/{ticker}.{exchange}"), params)

  df_out <- parse_api_df(content)

  cli::cli_alert_success("got {nrow(df_out)} quote{?s}")

  return(df_out)

}

#' Retrieves delayed quotes for US tickers
#'
#' Queries the delayed us quote endpoint
#' (<https://eodhd.com/financial-apis/live-v2-for-us-stocks-extended-quotes-2025>),
#' which returns a richer quote
#' (bid/ask, exchange, company name) than [eodhdR2::get_real_time()], for US
#' tickers only. Live data is never cached.
#'
#' @param tickers a character vector of US tickers (e.g. c("AAPL", "MSFT"))
#' @param fields an optional character vector restricting the returned fields
#' @inheritParams get_fundamentals
#'
#' @return A dataframe with one row per ticker
#' @export
#'
#' @examples
#' \dontrun{
#' set_token("YOUR_VALID_TOKEN")
#' df_quotes <- get_us_quote_delayed(c("AAPL", "MSFT"))
#' }
get_us_quote_delayed <- function(tickers = "AAPL",
                                 fields = NULL,
                                 check_quota = TRUE) {

  cli::cli_h1("retrieving delayed us quotes for {tickers}")

  if (check_quota) {
    get_quota_status()
  }

  params <- list(
    s = paste0(tickers, collapse = ","),
    fields = if (is.null(fields)) NULL else paste0(fields, collapse = ",")
  )

  content <- eodhd_content("us-quote-delayed", params)

  l_json <- jsonlite::fromJSON(content, flatten = TRUE)

  df_out <- l_json$data |>
    purrr::map(~ dplyr::as_tibble(purrr::map(.x, fix_null))) |>
    purrr::list_rbind()

  cli::cli_alert_success("got {nrow(df_out)} quote{?s}")

  return(df_out)

}

#' Retrieves historical tick data
#'
#' Queries the tick endpoint <https://eodhd.com/financial-apis/us-stock-market-tick-data-api>,
#' which returns every trade of a symbol within a time window. The window is
#' given in unix timestamps (seconds), as required by the api.
#'
#' @inheritParams get_fundamentals
#' @param first_time the start of the window, as a POSIXct or as a unix timestamp
#' @param last_time the end of the window, as a POSIXct or as a unix timestamp
#' @param limit maximum number of ticks (api default is 1, maximum 10000)
#'
#' @return A dataframe with tick data
#' @export
#'
#' @examples
#' \dontrun{
#' set_token("YOUR_VALID_TOKEN")
#' df_ticks <- get_ticks("AAPL", "US",
#'                       first_time = Sys.time() - 3600,
#'                       last_time = Sys.time())
#' }
get_ticks <- function(ticker = "AAPL",
                      exchange = "US",
                      first_time = Sys.time() - 3600,
                      last_time = Sys.time(),
                      limit = 1000,
                      cache_folder = get_default_cache(),
                      check_quota = TRUE) {

  cli::cli_h1("retrieving tick data for {ticker}|{exchange}")

  if (check_quota) {
    get_quota_status()
  }

  # the endpoint takes unix timestamps, in seconds
  params <- list(
    s = glue::glue("{ticker}.{exchange}"),
    from = floor(as.numeric(as.POSIXct(first_time, tz = "UTC"))),
    to = floor(as.numeric(as.POSIXct(last_time, tz = "UTC"))),
    limit = limit
  )

  f_out <- get_generic_cache_file(
    cache_folder,
    build_cache_name(glue::glue("{ticker}_{exchange}_ticks"), params)
  )

  if (fs::file_exists(f_out)) {
    return(read_cache(f_out))
  }

  content <- eodhd_content("ticks", params)

  # this endpoint answers column wise: one array per field
  l_json <- jsonlite::fromJSON(content)

  if (length(l_json) == 0) {

    df_out <- dplyr::tibble()

  } else {

    df_out <- dplyr::as_tibble(l_json)

    if ("ts" %in% names(df_out)) {
      df_out <- df_out |>
        dplyr::mutate(
          datetime = as.POSIXct(ts / 1000, origin = "1970-01-01", tz = "UTC"),
          .before = 1
        )
    }

  }

  write_cache(df_out, f_out)

  cli::cli_alert_success("got {nrow(df_out)} tick{?s}")

  return(df_out)

}

#' Retrieves end of day data for a whole exchange in a single call
#'
#' Queries the bulk endpoint
#' <https://eodhd.com/financial-apis/bulk-api-eod-splits-dividends>, which
#' returns the last trading day of every ticker of an exchange (or of the tickers
#' given in argument symbols).
#'
#' @inheritParams get_fundamentals
#' @param date an optional date. Default (NULL) is the last trading day.
#' @param type one of "eod" (default), "splits" or "dividends"
#' @param symbols an optional character vector of tickers, without the exchange
#'  (e.g. c("AAPL", "MSFT"))
#'
#' @return A dataframe with one row per ticker
#' @export
#'
#' @examples
#' \dontrun{
#' set_token("YOUR_VALID_TOKEN")
#' df_bulk <- get_bulk_eod("US", symbols = c("AAPL", "MSFT"))
#' }
get_bulk_eod <- function(exchange = "US",
                         date = NULL,
                         type = "eod",
                         symbols = NULL,
                         cache_folder = get_default_cache(),
                         check_quota = TRUE) {

  cli::cli_h1("retrieving bulk {type} data for {exchange}")

  possible_types <- c("eod", "splits", "dividends")
  if (!type %in% possible_types) {
    cli::cli_abort("value of {type} is not available in possible values: {possible_types}")
  }

  params <- list(
    date = if (is.null(date)) NULL else as.character(as.Date(date)),
    type = if (type == "eod") NULL else type,
    symbols = if (is.null(symbols)) NULL else paste0(symbols, collapse = ",")
  )

  df_out <- cached_api_df(
    endpoint = glue::glue("eod-bulk-last-day/{exchange}"),
    params = params,
    cache_folder = cache_folder,
    cache_prefix = glue::glue("{exchange}_bulk-{type}"),
    check_quota = check_quota,
    post_fun = function(df) fix_date_cols(df, c("date"))
  )

  cli::cli_alert_success("got {nrow(df_out)} rows of bulk {type} data")

  return(df_out)

}

#' Retrieves the historical market capitalisation of a company
#'
#' Queries <https://eodhd.com/financial-apis/stock-etfs-fundamental-data-feeds>
#' (historical market capitalisation), which returns the daily market cap of a
#' company. History is limited to the last year for most subscriptions.
#'
#' @inheritParams get_fundamentals
#' @param first_date the first date of the window. Default is one year ago.
#' @param last_date the last date of the window. Default is today.
#'
#' @return A dataframe with columns date and value
#' @export
#'
#' @examples
#' \dontrun{
#' set_token("YOUR_VALID_TOKEN")
#' df_cap <- get_historical_market_cap("AAPL", "US")
#' }
get_historical_market_cap <- function(ticker = "AAPL",
                                      exchange = "US",
                                      first_date = Sys.Date() - 365,
                                      last_date = Sys.Date(),
                                      cache_folder = get_default_cache(),
                                      check_quota = TRUE) {

  cli::cli_h1("retrieving historical market cap for {ticker}|{exchange}")

  params <- list(
    from = as.character(as.Date(first_date)),
    to = as.character(as.Date(last_date))
  )

  df_out <- cached_api_df(
    endpoint = glue::glue("historical-market-cap/{ticker}.{exchange}"),
    params = params,
    cache_folder = cache_folder,
    cache_prefix = glue::glue("{ticker}_{exchange}_market-cap"),
    check_quota = check_quota,
    post_fun = function(df) {
      df |>
        fix_date_cols("date") |>
        dplyr::mutate(ticker = ticker, exchange = exchange)
    }
  )

  cli::cli_alert_success("got {nrow(df_out)} rows of market cap data")

  return(df_out)

}

#' Retrieves technical indicators
#'
#' Queries the technical endpoint
#' <https://eodhd.com/financial-apis/technical-indicators-api>, which computes an
#' indicator (moving averages, rsi, macd, bollinger bands, beta, ..) on the server
#' side. See the api documentation for the full list of indicators and of the
#' parameters each one accepts.
#'
#' @inheritParams get_fundamentals
#' @param indicator the indicator to compute (api parameter "function"), e.g.
#'  "sma", "ema", "rsi", "macd", "bbands", "volatility", "stochastic"
#' @param period the number of periods used by the indicator. Default is 50.
#' @param first_date the first date of the output. Default is one year ago. Note
#'  that the api needs history before this date to compute the indicator, so ask
#'  for a window comfortably longer than the period.
#' @param last_date the last date of the output. Default is today.
#' @param order "d" for descending dates or "a" (default) for ascending
#' @param ... any other parameter accepted by the indicator (e.g. fast_period = 12)
#'
#' @return A dataframe with the indicator values
#' @export
#'
#' @examples
#' \dontrun{
#' set_token("YOUR_VALID_TOKEN")
#' df_sma <- get_technical("AAPL", "US", indicator = "sma", period = 50)
#' }
get_technical <- function(ticker = "AAPL",
                          exchange = "US",
                          indicator = "sma",
                          period = 50,
                          first_date = Sys.Date() - 365,
                          last_date = Sys.Date(),
                          order = "a",
                          ...,
                          cache_folder = get_default_cache(),
                          check_quota = TRUE) {

  cli::cli_h1("retrieving {indicator} for {ticker}|{exchange}")

  params <- c(
    list(
      "function" = indicator,
      period = period,
      from = as.character(as.Date(first_date)),
      to = as.character(as.Date(last_date)),
      order = order
    ),
    list(...)
  )

  df_out <- cached_api_df(
    endpoint = glue::glue("technical/{ticker}.{exchange}"),
    params = params,
    cache_folder = cache_folder,
    cache_prefix = glue::glue("{ticker}_{exchange}_technical"),
    check_quota = check_quota,
    post_fun = function(df) {
      df |>
        fix_date_cols("date") |>
        dplyr::mutate(ticker = ticker, exchange = exchange)
    }
  )

  cli::cli_alert_success("got {nrow(df_out)} rows of {indicator} data")

  return(df_out)

}
