#' Retrieves the symbols with options data
#'
#' Queries the Unicorn Bay options data of the eodhd marketplace
#' <https://eodhd.com/marketplace/unicornbay/options>, and returns the
#' underlying symbols that have contracts available.
#'
#' @inheritParams get_fundamentals
#' @param limit maximum number of rows (default 1000)
#' @param offset pagination offset (default 0)
#'
#' @return A dataframe with one column, underlying_symbol
#' @export
#'
#' @examples
#' \dontrun{
#' set_token("YOUR_VALID_TOKEN")
#' df_underlyings <- get_options_underlyings()
#' }
get_options_underlyings <- function(limit = 1000,
                                    offset = 0,
                                    cache_folder = get_default_cache(),
                                    check_quota = TRUE) {

  cli::cli_h1("retrieving option underlying symbols")

  params <- list(
    "page[limit]" = limit,
    "page[offset]" = offset
  )

  df_out <- cached_api_df(
    endpoint = "mp/unicornbay/options/underlying-symbols",
    params = params,
    cache_folder = cache_folder,
    cache_prefix = "options-underlyings",
    check_quota = check_quota,
    post_fun = function(df) {
      # the endpoint answers a bare list of strings, which lands in a column
      # named "value" -- name it after what it actually holds
      if (identical(names(df), "value")) names(df) <- "underlying_symbol"
      df
    }
  )

  cli::cli_alert_success("got {nrow(df_out)} underlying symbol{?s}")

  return(df_out)

}

#' Retrieves option contracts
#'
#' Queries the contracts of the Unicorn Bay options data
#' <https://eodhd.com/marketplace/unicornbay/options>. Each row is one
#' contract, with its strike, expiration, greeks and implied volatility.
#'
#' @inheritParams get_fundamentals
#' @param underlying_symbol the underlying symbol, without the exchange
#'  (e.g. "AAPL"). This endpoint only covers US options, so a symbol given with
#'  its exchange ("AAPL.US") is trimmed for you.
#' @param contract an optional single contract code (e.g. "AAPL270115C00200000").
#'  When given, the underlying symbol is ignored by the api.
#' @param type an optional type of contract ("call" or "put")
#' @param exp_date a single expiration date, or NULL
#' @param first_exp_date an optional first expiration date of the window
#' @param last_exp_date an optional last expiration date of the window
#' @param first_strike an optional lower bound of the strike
#' @param last_strike an optional upper bound of the strike
#' @param sort an optional sort expression (e.g. "-exp_date")
#' @param limit maximum number of rows (default 100, maximum 1000)
#' @param offset pagination offset (default 0)
#'
#' @return A dataframe with the option contracts
#' @export
#'
#' @examples
#' \dontrun{
#' set_token("YOUR_VALID_TOKEN")
#' df_contracts <- get_options_contracts("AAPL", type = "call")
#' }
get_options_contracts <- function(underlying_symbol = "AAPL",
                                  contract = NULL,
                                  type = NULL,
                                  exp_date = NULL,
                                  first_exp_date = NULL,
                                  last_exp_date = NULL,
                                  first_strike = NULL,
                                  last_strike = NULL,
                                  sort = NULL,
                                  limit = 100,
                                  offset = 0,
                                  cache_folder = get_default_cache(),
                                  check_quota = TRUE) {

  underlying_symbol <- trim_exchange(underlying_symbol)

  cli::cli_h1("retrieving option contracts for {underlying_symbol}")

  params <- list(
    "filter[contract]" = contract,
    "filter[underlying_symbol]" = underlying_symbol,
    "filter[type]" = type,
    "filter[exp_date_eq]" = if (is.null(exp_date)) NULL else as.character(as.Date(exp_date)),
    "filter[exp_date_from]" = if (is.null(first_exp_date)) NULL else as.character(as.Date(first_exp_date)),
    "filter[exp_date_to]" = if (is.null(last_exp_date)) NULL else as.character(as.Date(last_exp_date)),
    "filter[strike_from]" = first_strike,
    "filter[strike_to]" = last_strike,
    sort = sort,
    "page[limit]" = limit,
    "page[offset]" = offset
  )

  df_out <- cached_api_df(
    endpoint = "mp/unicornbay/options/contracts",
    params = params,
    cache_folder = cache_folder,
    cache_prefix = "options-contracts",
    check_quota = check_quota,
    post_fun = function(df) fix_date_cols(df, c("exp_date", "tradetime", "date"))
  )

  cli::cli_alert_success("got {nrow(df_out)} contract{?s}")

  return(df_out)

}

#' Retrieves the end of day prices of option contracts
#'
#' Queries the eod endpoint of the Unicorn Bay options data
#' <https://eodhd.com/marketplace/unicornbay/options>, with one row per
#' contract and trading day.
#'
#' @inheritParams get_options_contracts
#' @param first_date an optional first trading date of the window
#' @param last_date an optional last trading date of the window
#' @param date a single trading date, or NULL
#'
#' @return A dataframe with the end of day prices of the contracts
#' @export
#'
#' @examples
#' \dontrun{
#' set_token("YOUR_VALID_TOKEN")
#' df_eod <- get_options_eod("AAPL")
#' }
get_options_eod <- function(underlying_symbol = "AAPL",
                            contract = NULL,
                            type = NULL,
                            date = NULL,
                            first_date = NULL,
                            last_date = NULL,
                            exp_date = NULL,
                            first_exp_date = NULL,
                            last_exp_date = NULL,
                            first_strike = NULL,
                            last_strike = NULL,
                            sort = NULL,
                            limit = 100,
                            offset = 0,
                            cache_folder = get_default_cache(),
                            check_quota = TRUE) {

  underlying_symbol <- trim_exchange(underlying_symbol)

  cli::cli_h1("retrieving option eod prices for {underlying_symbol}")

  params <- list(
    "filter[contract]" = contract,
    "filter[underlying_symbol]" = underlying_symbol,
    "filter[type]" = type,
    "filter[tradetime_eq]" = if (is.null(date)) NULL else as.character(as.Date(date)),
    "filter[tradetime_from]" = if (is.null(first_date)) NULL else as.character(as.Date(first_date)),
    "filter[tradetime_to]" = if (is.null(last_date)) NULL else as.character(as.Date(last_date)),
    "filter[exp_date_eq]" = if (is.null(exp_date)) NULL else as.character(as.Date(exp_date)),
    "filter[exp_date_from]" = if (is.null(first_exp_date)) NULL else as.character(as.Date(first_exp_date)),
    "filter[exp_date_to]" = if (is.null(last_exp_date)) NULL else as.character(as.Date(last_exp_date)),
    "filter[strike_from]" = first_strike,
    "filter[strike_to]" = last_strike,
    sort = sort,
    "page[limit]" = limit,
    "page[offset]" = offset
  )

  df_out <- cached_api_df(
    endpoint = "mp/unicornbay/options/eod",
    params = params,
    cache_folder = cache_folder,
    cache_prefix = "options-eod",
    check_quota = check_quota,
    post_fun = function(df) fix_date_cols(df, c("exp_date", "tradetime", "date"))
  )

  cli::cli_alert_success("got {nrow(df_out)} row{?s} of option prices")

  return(df_out)

}

#' Removes the exchange suffix of a ticker ("AAPL.US" -> "AAPL")
#'
#' @noRd
trim_exchange <- function(x) {

  if (is.null(x)) {
    return(NULL)
  }

  sub("\\..*$", "", x)

}
