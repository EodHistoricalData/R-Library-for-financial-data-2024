#' Retrieves the earnings calendar
#'
#' Queries <https://eodhd.com/financial-apis/calendar-upcoming-earnings-ipos-and-splits>
#' and returns reported and upcoming earnings, with estimate, actual value and
#' surprise.
#'
#' @inheritParams get_fundamentals
#' @param first_date the first date of the window. Default is today.
#' @param last_date the last date of the window. Default is in one month.
#' @param symbols an optional character vector of tickers with exchange
#'  (e.g. c("AAPL.US", "MSFT.US")). Default (NULL) returns every company.
#'
#' @return A dataframe with the earnings calendar
#' @export
#'
#' @examples
#' \dontrun{
#' set_token("YOUR_VALID_TOKEN")
#' df_earnings <- get_earnings(symbols = "AAPL.US")
#' }
get_earnings <- function(first_date = Sys.Date(),
                         last_date = Sys.Date() + 30,
                         symbols = NULL,
                         cache_folder = get_default_cache(),
                         check_quota = TRUE) {

  cli::cli_h1("retrieving earnings calendar")

  params <- list(
    from = as.character(as.Date(first_date)),
    to = as.character(as.Date(last_date)),
    symbols = if (is.null(symbols)) NULL else paste0(symbols, collapse = ",")
  )

  df_out <- cached_api_df(
    endpoint = "calendar/earnings",
    params = params,
    cache_folder = cache_folder,
    cache_prefix = "calendar-earnings",
    check_quota = check_quota,
    element = "earnings",
    post_fun = function(df) fix_date_cols(df, c("report_date", "date"))
  )

  cli::cli_alert_success("got {nrow(df_out)} earnings event{?s}")

  return(df_out)

}

#' Retrieves analyst estimates and their revisions
#'
#' Queries the earning trends endpoint
#' <https://eodhd.com/financial-apis/calendar-upcoming-earnings-ipos-and-splits>,
#' which returns, for each period, the average analyst estimate for earnings and
#' revenue, together with the revisions of the last months.
#'
#' @inheritParams get_fundamentals
#' @param symbols a character vector of tickers with exchange
#'  (e.g. c("AAPL.US", "MSFT.US"))
#'
#' @return A dataframe with the analyst estimates
#' @export
#'
#' @examples
#' \dontrun{
#' set_token("YOUR_VALID_TOKEN")
#' df_trends <- get_earnings_trends("AAPL.US")
#' }
get_earnings_trends <- function(symbols = "AAPL.US",
                                cache_folder = get_default_cache(),
                                check_quota = TRUE) {

  cli::cli_h1("retrieving earning trends for {symbols}")

  params <- list(symbols = paste0(symbols, collapse = ","))

  df_out <- cached_api_df(
    endpoint = "calendar/trends",
    params = params,
    cache_folder = cache_folder,
    cache_prefix = "calendar-trends",
    check_quota = check_quota,
    element = "trends",
    post_fun = function(df) fix_date_cols(df, "date")
  )

  cli::cli_alert_success("got {nrow(df_out)} row{?s} of analyst estimates")

  return(df_out)

}

#' Retrieves the splits calendar
#'
#' Queries <https://eodhd.com/financial-apis/calendar-upcoming-earnings-ipos-and-splits>
#' and returns the stock splits of a period, including the upcoming ones.
#'
#' @inheritParams get_fundamentals
#' @param first_date the first date of the window. Default is today.
#' @param last_date the last date of the window. Default is in one month.
#'
#' @return A dataframe with the splits calendar
#' @export
#'
#' @examples
#' \dontrun{
#' set_token("YOUR_VALID_TOKEN")
#' df_splits <- get_splits_calendar()
#' }
get_splits_calendar <- function(first_date = Sys.Date(),
                                last_date = Sys.Date() + 30,
                                cache_folder = get_default_cache(),
                                check_quota = TRUE) {

  cli::cli_h1("retrieving splits calendar")

  params <- list(
    from = as.character(as.Date(first_date)),
    to = as.character(as.Date(last_date))
  )

  df_out <- cached_api_df(
    endpoint = "calendar/splits",
    params = params,
    cache_folder = cache_folder,
    cache_prefix = "calendar-splits",
    check_quota = check_quota,
    element = "splits",
    post_fun = function(df) fix_date_cols(df, "split_date")
  )

  cli::cli_alert_success("got {nrow(df_out)} split{?s}")

  return(df_out)

}

#' Retrieves the dividend calendar
#'
#' Queries the dividend calendar endpoint of eodhd. The api requires either a
#' symbol or a single date, so one of arguments symbol and date must be given.
#'
#' @inheritParams get_fundamentals
#' @param symbol a ticker with exchange (e.g. "AAPL.US")
#' @param date a single date. Used when symbol is NULL.
#' @param first_date an optional first date, to narrow the output of a symbol query
#' @param last_date an optional last date, to narrow the output of a symbol query
#' @param limit maximum number of rows (default 100)
#' @param offset pagination offset (default 0)
#'
#' @return A dataframe with the dividend calendar
#' @export
#'
#' @examples
#' \dontrun{
#' set_token("YOUR_VALID_TOKEN")
#' df_div <- get_dividends_calendar(symbol = "AAPL.US")
#' }
get_dividends_calendar <- function(symbol = NULL,
                                   date = NULL,
                                   first_date = NULL,
                                   last_date = NULL,
                                   limit = 100,
                                   offset = 0,
                                   cache_folder = get_default_cache(),
                                   check_quota = TRUE) {

  if (is.null(symbol) && is.null(date)) {
    cli::cli_abort("the dividend calendar needs either a symbol or a single date")
  }

  cli::cli_h1("retrieving dividend calendar")

  params <- list(
    "filter[symbol]" = symbol,
    "filter[date_eq]" = if (is.null(date)) NULL else as.character(as.Date(date)),
    "filter[date_from]" = if (is.null(first_date)) NULL else as.character(as.Date(first_date)),
    "filter[date_to]" = if (is.null(last_date)) NULL else as.character(as.Date(last_date)),
    "page[limit]" = limit,
    "page[offset]" = offset
  )

  df_out <- cached_api_df(
    endpoint = "calendar/dividends",
    params = params,
    cache_folder = cache_folder,
    cache_prefix = "calendar-dividends",
    check_quota = check_quota,
    post_fun = function(df) fix_date_cols(df, "date")
  )

  cli::cli_alert_success("got {nrow(df_out)} dividend{?s}")

  return(df_out)

}
