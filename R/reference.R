#' Searches for tickers, companies and isins
#'
#' Queries the search endpoint <https://eodhd.com/financial-apis/search-api-for-stocks-etfs-mutual-funds>,
#' which accepts a company name, a ticker or an isin and returns the matching
#' instruments.
#'
#' @param query the text to search for (e.g. "apple", "AAPL", "US0378331005")
#' @param limit maximum number of results (default 15, maximum 500)
#' @param type an optional instrument type ("stock", "etf", "fund", "bonds",
#'  "index", "commodity", "crypto")
#' @param exchange an optional exchange code, to restrict the search
#' @inheritParams get_fundamentals
#'
#' @return A dataframe with the matching instruments
#' @export
#'
#' @examples
#' \dontrun{
#' set_token("YOUR_VALID_TOKEN")
#' df_search <- get_search("apple")
#' }
get_search <- function(query,
                       limit = 15,
                       type = NULL,
                       exchange = NULL,
                       cache_folder = get_default_cache(),
                       check_quota = TRUE) {

  cli::cli_h1("searching for {query}")

  params <- list(limit = limit, type = type, exchange = exchange)

  # the query is a path segment, not a parameter, so it has to be escaped here
  query_escaped <- utils::URLencode(query, reserved = TRUE)

  df_out <- cached_api_df(
    endpoint = glue::glue("search/{query_escaped}"),
    params = params,
    cache_folder = cache_folder,
    cache_prefix = glue::glue("search_{gsub('[^A-Za-z0-9]', '', query)}"),
    check_quota = check_quota
  )

  cli::cli_alert_success("got {nrow(df_out)} result{?s}")

  return(df_out)

}

#' Retrieves the details of an exchange
#'
#' Queries <https://eodhd.com/financial-apis/exchanges-api-list-of-tickers-and-trading-hours>
#' and returns trading hours, holidays and the number of active tickers of an
#' exchange.
#'
#' @inheritParams get_fundamentals
#' @param first_date optional first date of the holiday window
#' @param last_date optional last date of the holiday window
#'
#' @return A list with the exchange details (including dataframes of trading
#'  hours and holidays)
#' @export
#'
#' @examples
#' \dontrun{
#' set_token("YOUR_VALID_TOKEN")
#' l_details <- get_exchange_details("US")
#' }
get_exchange_details <- function(exchange = "US",
                                 first_date = NULL,
                                 last_date = NULL,
                                 cache_folder = get_default_cache(),
                                 check_quota = TRUE) {

  cli::cli_h1("retrieving details of exchange {exchange}")

  if (check_quota) {
    get_quota_status()
  }

  params <- list(
    from = if (is.null(first_date)) NULL else as.character(as.Date(first_date)),
    to = if (is.null(last_date)) NULL else as.character(as.Date(last_date))
  )

  f_out <- get_generic_cache_file(
    cache_folder,
    build_cache_name(glue::glue("{exchange}_exchange-details"), params)
  )

  if (fs::file_exists(f_out)) {
    return(read_cache(f_out))
  }

  content <- eodhd_content(glue::glue("exchange-details/{exchange}"), params)

  l_out <- jsonlite::fromJSON(content)

  write_cache(l_out, f_out)

  cli::cli_alert_success("got details of {l_out$Name} ({l_out$ActiveTickers} active tickers)")

  return(l_out)

}

#' Retrieves the history of ticker changes
#'
#' Queries <https://eodhd.com/financial-apis/exchanges-api-list-of-tickers-and-trading-hours>
#' (symbol change history) and returns the tickers that were renamed within a
#' period. Useful for keeping a database of symbols in sync.
#'
#' @inheritParams get_fundamentals
#' @param first_date the first date of the window. Default is 30 days ago.
#' @param last_date the last date of the window. Default is today.
#' @param exchange an optional exchange code, to restrict the output
#'
#' @return A dataframe with old symbol, new symbol and effective date
#' @export
#'
#' @examples
#' \dontrun{
#' set_token("YOUR_VALID_TOKEN")
#' df_changes <- get_symbol_change_history()
#' }
get_symbol_change_history <- function(first_date = Sys.Date() - 30,
                                      last_date = Sys.Date(),
                                      exchange = NULL,
                                      cache_folder = get_default_cache(),
                                      check_quota = TRUE) {

  cli::cli_h1("retrieving symbol changes from {first_date} to {last_date}")

  params <- list(
    from = as.character(as.Date(first_date)),
    to = as.character(as.Date(last_date)),
    ex = exchange
  )

  df_out <- cached_api_df(
    endpoint = "symbol-change-history",
    params = params,
    cache_folder = cache_folder,
    cache_prefix = "symbol-changes",
    check_quota = check_quota,
    post_fun = function(df) fix_date_cols(df, "effective")
  )

  cli::cli_alert_success("got {nrow(df_out)} symbol change{?s}")

  return(df_out)

}

#' Maps a security between identifiers (ticker, isin, figi, lei, cusip, cik)
#'
#' Queries the id mapping endpoint of eodhd. Give it one identifier and it
#' returns all the others.
#'
#' @param symbol an optional ticker (e.g. "AAPL")
#' @param exchange an optional exchange code, used together with symbol
#' @param isin,figi,lei,cusip,cik optional identifiers, one is enough
#' @param limit maximum number of rows (default 50)
#' @param offset pagination offset (default 0)
#' @inheritParams get_fundamentals
#'
#' @return A dataframe with the matching identifiers
#' @export
#'
#' @examples
#' \dontrun{
#' set_token("YOUR_VALID_TOKEN")
#' df_ids <- get_id_mapping(symbol = "AAPL")
#' }
get_id_mapping <- function(symbol = NULL,
                           exchange = NULL,
                           isin = NULL,
                           figi = NULL,
                           lei = NULL,
                           cusip = NULL,
                           cik = NULL,
                           limit = 50,
                           offset = 0,
                           cache_folder = get_default_cache(),
                           check_quota = TRUE) {

  cli::cli_h1("retrieving identifiers")

  params <- list(
    "filter[symbol]" = symbol,
    "filter[ex]" = exchange,
    "filter[isin]" = isin,
    "filter[figi]" = figi,
    "filter[lei]" = lei,
    "filter[cusip]" = cusip,
    "filter[cik]" = cik,
    "page[limit]" = limit,
    "page[offset]" = offset
  )

  df_out <- cached_api_df(
    endpoint = "id-mapping",
    params = params,
    cache_folder = cache_folder,
    cache_prefix = "id-mapping",
    check_quota = check_quota
  )

  cli::cli_alert_success("got {nrow(df_out)} row{?s}")

  return(df_out)

}

#' Screens stocks by fundamentals, price and technical signals
#'
#' Queries the screener endpoint <https://eodhd.com/financial-apis/stock-market-screener-api>.
#' Filters are given as a list of conditions, each one a list of field, operation
#' and value -- the function converts them to the json string the api expects.
#'
#' @param filters a list of conditions, e.g.
#'  list(list("market_capitalization", ">", 1e12), list("exchange", "=", "us")).
#'  A character string with the json expected by the api is also accepted.
#' @param signals an optional character vector of signals (e.g. "bookvalue_neg",
#'  "200d_new_lo")
#' @param sort an optional sorting rule (e.g. "market_capitalization.desc")
#' @param limit maximum number of rows (default 50, maximum 100)
#' @param offset pagination offset (default 0)
#' @inheritParams get_fundamentals
#'
#' @return A dataframe with the screened companies
#' @export
#'
#' @examples
#' \dontrun{
#' set_token("YOUR_VALID_TOKEN")
#' df_screen <- get_screener(
#'   filters = list(list("market_capitalization", ">", 1e12))
#' )
#' }
get_screener <- function(filters = NULL,
                         signals = NULL,
                         sort = NULL,
                         limit = 50,
                         offset = 0,
                         cache_folder = get_default_cache(),
                         check_quota = TRUE) {

  cli::cli_h1("screening stocks")

  if (is.list(filters)) {
    filters <- as.character(
      jsonlite::toJSON(filters, auto_unbox = TRUE)
    )
  }

  params <- list(
    filters = filters,
    signals = if (is.null(signals)) NULL else paste0(signals, collapse = ","),
    sort = sort,
    limit = limit,
    offset = offset
  )

  df_out <- cached_api_df(
    endpoint = "screener",
    params = params,
    cache_folder = cache_folder,
    cache_prefix = "screener",
    check_quota = check_quota,
    post_fun = function(df) fix_date_cols(df, "last_day_data_date")
  )

  cli::cli_alert_success("got {nrow(df_out)} compan{?y/ies}")

  return(df_out)

}
