#' Retrieves a macroeconomic indicator of a country
#'
#' Queries <https://eodhd.com/financial-apis/macroeconomics-data-and-macro-indicators-api>,
#' which serves the World Bank series (gdp, inflation, unemployment, population
#' and 40 others) by country.
#'
#' @inheritParams get_fundamentals
#' @param country a country code in ISO 3166-1 alpha 3 (e.g. "USA", "DEU", "BRA")
#' @param indicator the code of the indicator (default "gdp_current_usd"). The
#'  full list is at the endpoint documentation.
#'
#' @return A dataframe with the historical values of the indicator
#' @export
#'
#' @examples
#' \dontrun{
#' set_token("YOUR_VALID_TOKEN")
#' df_gdp <- get_macro_indicator("USA", "gdp_current_usd")
#' }
get_macro_indicator <- function(country = "USA",
                                indicator = "gdp_current_usd",
                                cache_folder = get_default_cache(),
                                check_quota = TRUE) {

  cli::cli_h1("retrieving {indicator} for {country}")

  df_out <- cached_api_df(
    endpoint = glue::glue("macro-indicator/{country}"),
    params = list(indicator = indicator),
    cache_folder = cache_folder,
    cache_prefix = glue::glue("macro-{country}"),
    check_quota = check_quota,
    post_fun = function(df) fix_date_cols(df, "Date")
  )

  cli::cli_alert_success("got {nrow(df_out)} observation{?s}")

  return(df_out)

}

#' Retrieves the economic calendar
#'
#' Queries <https://eodhd.com/financial-apis/macroeconomics-data-and-macro-indicators-api>
#' for the scheduled and released macroeconomic events, with actual, estimate and
#' previous values.
#'
#' @inheritParams get_fundamentals
#' @param first_date the first date of the window. Default is today.
#' @param last_date the last date of the window. Default is in one month.
#' @param country an optional country code in ISO 3166-1 alpha 2 (e.g. "US")
#' @param comparison an optional comparison period ("mom", "qoq" or "yoy")
#' @param limit maximum number of events (default 50, maximum 1000)
#' @param offset pagination offset (default 0)
#'
#' @return A dataframe with the economic events
#' @export
#'
#' @examples
#' \dontrun{
#' set_token("YOUR_VALID_TOKEN")
#' df_events <- get_economic_events(country = "US")
#' }
get_economic_events <- function(first_date = Sys.Date(),
                                last_date = Sys.Date() + 30,
                                country = NULL,
                                comparison = NULL,
                                limit = 50,
                                offset = 0,
                                cache_folder = get_default_cache(),
                                check_quota = TRUE) {

  cli::cli_h1("retrieving economic events")

  params <- list(
    from = as.character(as.Date(first_date)),
    to = as.character(as.Date(last_date)),
    country = country,
    comparison = comparison,
    limit = limit,
    offset = offset
  )

  df_out <- cached_api_df(
    endpoint = "economic-events",
    params = params,
    cache_folder = cache_folder,
    cache_prefix = "economic-events",
    check_quota = check_quota,
    post_fun = function(df) fix_date_cols(df, "date")
  )

  cli::cli_alert_success("got {nrow(df_out)} event{?s}")

  return(df_out)

}

#' Retrieves the historical prices of a commodity
#'
#' Queries the commodities endpoint of eodhd, which serves the daily, weekly and
#' monthly series of energy, metals and agricultural commodities.
#'
#' @inheritParams get_fundamentals
#' @param code the code of the commodity (e.g. "WTI", "BRENT", "GOLD")
#' @param interval "daily" (default), "weekly" or "monthly"
#' @param first_date an optional first date of the window
#' @param last_date an optional last date of the window
#'
#' @return A dataframe with the historical prices of the commodity
#' @export
#'
#' @examples
#' \dontrun{
#' set_token("YOUR_VALID_TOKEN")
#' df_wti <- get_commodities("WTI")
#' }
get_commodities <- function(code = "WTI",
                            interval = "daily",
                            first_date = NULL,
                            last_date = NULL,
                            cache_folder = get_default_cache(),
                            check_quota = TRUE) {

  interval <- match.arg(interval, c("daily", "weekly", "monthly"))

  cli::cli_h1("retrieving {interval} prices of commodity {code}")

  params <- list(
    interval = interval,
    from = if (is.null(first_date)) NULL else as.character(as.Date(first_date)),
    to = if (is.null(last_date)) NULL else as.character(as.Date(last_date))
  )

  df_out <- cached_api_df(
    endpoint = glue::glue("commodities/historical/{code}"),
    params = params,
    cache_folder = cache_folder,
    cache_prefix = glue::glue("commodities-{code}"),
    check_quota = check_quota,
    post_fun = function(df) fix_date_cols(df, "date")
  )

  cli::cli_alert_success("got {nrow(df_out)} observation{?s}")

  return(df_out)

}

#' Retrieves the rates of the US Treasury
#'
#' Queries the US Treasury endpoints of eodhd: the daily par yield curve, the
#' bill rates, the long term rates and the real yield curve.
#'
#' @inheritParams get_fundamentals
#' @param type one of "yield" (default, the par yield curve), "bill",
#'  "long-term" or "real-yield"
#' @param first_date an optional first date of the window
#' @param last_date an optional last date of the window
#' @param year an optional single year (e.g. 2026), as an alternative to the dates
#' @param limit maximum number of rows (default 100)
#' @param offset pagination offset (default 0)
#'
#' @return A dataframe with the treasury rates
#' @export
#'
#' @examples
#' \dontrun{
#' set_token("YOUR_VALID_TOKEN")
#' df_ust <- get_ust_rates("yield", first_date = "2026-01-01")
#' }
get_ust_rates <- function(type = "yield",
                          first_date = NULL,
                          last_date = NULL,
                          year = NULL,
                          limit = 100,
                          offset = 0,
                          cache_folder = get_default_cache(),
                          check_quota = TRUE) {

  type <- match.arg(type, c("yield", "bill", "long-term", "real-yield"))

  endpoint <- switch(
    type,
    "yield" = "ust/yield-rates",
    "bill" = "ust/bill-rates",
    "long-term" = "ust/long-term-rates",
    "real-yield" = "ust/real-yield-rates"
  )

  cli::cli_h1("retrieving us treasury {type} rates")

  params <- list(
    from = if (is.null(first_date)) NULL else as.character(as.Date(first_date)),
    to = if (is.null(last_date)) NULL else as.character(as.Date(last_date)),
    "filter[year]" = year,
    "page[limit]" = limit,
    "page[offset]" = offset
  )

  df_out <- cached_api_df(
    endpoint = endpoint,
    params = params,
    cache_folder = cache_folder,
    cache_prefix = glue::glue("ust-{type}"),
    check_quota = check_quota,
    post_fun = function(df) fix_date_cols(df, "date")
  )

  cli::cli_alert_success("got {nrow(df_out)} row{?s} of treasury rates")

  return(df_out)

}

#' Retrieves the policy rates of the central banks
#'
#' Queries the policy rates endpoint of eodhd, with the historical decisions of
#' the central banks (fed funds target, ecb deposit rate, and so on).
#'
#' @inheritParams get_fundamentals
#' @param code an optional code of the rate (e.g. "FED_FUNDS_TARGET_UPPER")
#' @param country an optional country code (e.g. "US")
#' @param central_bank an optional central bank code (e.g. "FED", "ECB")
#' @param first_date an optional first date of the window
#' @param last_date an optional last date of the window
#' @param limit maximum number of rows (default 100)
#' @param offset pagination offset (default 0)
#'
#' @return A dataframe with the policy rates
#' @export
#'
#' @examples
#' \dontrun{
#' set_token("YOUR_VALID_TOKEN")
#' df_policy <- get_policy_rates(central_bank = "FED")
#' }
get_policy_rates <- function(code = NULL,
                             country = NULL,
                             central_bank = NULL,
                             first_date = NULL,
                             last_date = NULL,
                             limit = 100,
                             offset = 0,
                             cache_folder = get_default_cache(),
                             check_quota = TRUE) {

  cli::cli_h1("retrieving policy rates")

  params <- list(
    "filter[code]" = code,
    "filter[country]" = country,
    "filter[central_bank]" = central_bank,
    "filter[from]" = if (is.null(first_date)) NULL else as.character(as.Date(first_date)),
    "filter[to]" = if (is.null(last_date)) NULL else as.character(as.Date(last_date)),
    "page[limit]" = limit,
    "page[offset]" = offset
  )

  df_out <- cached_api_df(
    endpoint = "rates/policy-rates",
    params = params,
    cache_folder = cache_folder,
    cache_prefix = "policy-rates",
    check_quota = check_quota,
    post_fun = function(df) fix_date_cols(df, c("date", "effective_date"))
  )

  cli::cli_alert_success("got {nrow(df_out)} row{?s} of policy rates")

  return(df_out)

}

#' Retrieves the overnight reference rates
#'
#' Queries the reference rates endpoint of eodhd, with the benchmark overnight
#' rates (SOFR, ESTR, SONIA and others).
#'
#' @inheritParams get_fundamentals
#' @param code an optional code of the rate (e.g. "SOFR")
#' @param currency an optional currency of the rate ("USD", "GBP" or "EUR")
#' @param first_date an optional first date of the window
#' @param last_date an optional last date of the window
#' @param limit maximum number of rows (default 100)
#' @param offset pagination offset (default 0)
#'
#' @return A dataframe with the reference rates
#' @export
#'
#' @examples
#' \dontrun{
#' set_token("YOUR_VALID_TOKEN")
#' df_sofr <- get_reference_rates(code = "SOFR")
#' }
get_reference_rates <- function(code = NULL,
                                currency = NULL,
                                first_date = NULL,
                                last_date = NULL,
                                limit = 100,
                                offset = 0,
                                cache_folder = get_default_cache(),
                                check_quota = TRUE) {

  cli::cli_h1("retrieving reference rates")

  params <- list(
    "filter[code]" = code,
    "filter[currency]" = currency,
    "filter[from]" = if (is.null(first_date)) NULL else as.character(as.Date(first_date)),
    "filter[to]" = if (is.null(last_date)) NULL else as.character(as.Date(last_date)),
    "page[limit]" = limit,
    "page[offset]" = offset
  )

  df_out <- cached_api_df(
    endpoint = "rates/reference-rates",
    params = params,
    cache_folder = cache_folder,
    cache_prefix = "reference-rates",
    check_quota = check_quota,
    post_fun = function(df) fix_date_cols(df, "date")
  )

  cli::cli_alert_success("got {nrow(df_out)} row{?s} of reference rates")

  return(df_out)

}

#' Retrieves the funding stress spreads
#'
#' Queries the funding stress endpoint of eodhd, with the spreads used to monitor
#' the stress of the money market.
#'
#' @inheritParams get_fundamentals
#' @param code an optional code of the spread
#' @param first_date an optional first date of the window
#' @param last_date an optional last date of the window
#'
#' @return A dataframe with the funding stress spreads
#' @export
#'
#' @examples
#' \dontrun{
#' set_token("YOUR_VALID_TOKEN")
#' df_spreads <- get_funding_stress_spreads()
#' }
get_funding_stress_spreads <- function(code = NULL,
                                       first_date = NULL,
                                       last_date = NULL,
                                       cache_folder = get_default_cache(),
                                       check_quota = TRUE) {

  cli::cli_h1("retrieving funding stress spreads")

  params <- list(
    "filter[code]" = code,
    "filter[from]" = if (is.null(first_date)) NULL else as.character(as.Date(first_date)),
    "filter[to]" = if (is.null(last_date)) NULL else as.character(as.Date(last_date))
  )

  df_out <- cached_api_df(
    endpoint = "spreads/funding-stress",
    params = params,
    cache_folder = cache_folder,
    cache_prefix = "funding-stress",
    check_quota = check_quota,
    post_fun = function(df) fix_date_cols(df, "date")
  )

  cli::cli_alert_success("got {nrow(df_out)} row{?s} of spreads")

  return(df_out)

}
