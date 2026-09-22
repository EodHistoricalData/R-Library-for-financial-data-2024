#' Retrieves the sovereign risk premium
#'
#' Queries the credit risk endpoints of eodhd, which serve the country risk
#' premium built from the sovereign rating and the default spread.
#'
#' @inheritParams get_fundamentals
#' @param country an optional country code (e.g. "BR")
#' @param region an optional region name (e.g. "Latin America")
#' @param as_of an optional reference date. Default (NULL) is the latest release.
#' @param limit maximum number of rows (default 100)
#' @param offset pagination offset (default 0)
#'
#' @return A dataframe with the sovereign risk premium
#' @export
#'
#' @examples
#' \dontrun{
#' set_token("YOUR_VALID_TOKEN")
#' df_premium <- get_sovereign_risk_premium(country = "BR")
#' }
get_sovereign_risk_premium <- function(country = NULL,
                                       region = NULL,
                                       as_of = NULL,
                                       limit = 100,
                                       offset = 0,
                                       cache_folder = get_default_cache(),
                                       check_quota = TRUE) {

  cli::cli_h1("retrieving sovereign risk premium")

  params <- list(
    "filter[country]" = country,
    "filter[region]" = region,
    "filter[as_of]" = if (is.null(as_of)) NULL else as.character(as.Date(as_of)),
    "page[limit]" = limit,
    "page[offset]" = offset
  )

  df_out <- cached_api_df(
    endpoint = "credit-risk/sovereign/risk-premium",
    params = params,
    cache_folder = cache_folder,
    cache_prefix = "risk-premium",
    check_quota = check_quota,
    post_fun = function(df) fix_date_cols(df, c("as_of", "date"))
  )

  cli::cli_alert_success("got {nrow(df_out)} row{?s}")

  return(df_out)

}

#' Retrieves the sovereign credit ratings
#'
#' Queries the credit risk endpoints of eodhd for the ratings of the three major
#' agencies by country.
#'
#' @inheritParams get_sovereign_risk_premium
#'
#' @return A dataframe with the sovereign credit ratings
#' @export
#'
#' @examples
#' \dontrun{
#' set_token("YOUR_VALID_TOKEN")
#' df_ratings <- get_sovereign_credit_ratings()
#' }
get_sovereign_credit_ratings <- function(country = NULL,
                                         as_of = NULL,
                                         limit = 100,
                                         offset = 0,
                                         cache_folder = get_default_cache(),
                                         check_quota = TRUE) {

  cli::cli_h1("retrieving sovereign credit ratings")

  params <- list(
    "filter[country]" = country,
    "filter[as_of]" = if (is.null(as_of)) NULL else as.character(as.Date(as_of)),
    "page[limit]" = limit,
    "page[offset]" = offset
  )

  df_out <- cached_api_df(
    endpoint = "credit-risk/sovereign/credit-ratings",
    params = params,
    cache_folder = cache_folder,
    cache_prefix = "credit-ratings",
    check_quota = check_quota,
    post_fun = function(df) fix_date_cols(df, c("as_of", "date"))
  )

  cli::cli_alert_success("got {nrow(df_out)} row{?s}")

  return(df_out)

}

#' Retrieves the sovereign cds spreads
#'
#' Queries the credit risk endpoints of eodhd for the credit default swap spreads
#' of the sovereign issuers.
#'
#' @inheritParams get_sovereign_risk_premium
#'
#' @return A dataframe with the sovereign cds spreads
#' @export
#'
#' @examples
#' \dontrun{
#' set_token("YOUR_VALID_TOKEN")
#' df_cds <- get_sovereign_cds_spreads()
#' }
get_sovereign_cds_spreads <- function(country = NULL,
                                      as_of = NULL,
                                      limit = 100,
                                      offset = 0,
                                      cache_folder = get_default_cache(),
                                      check_quota = TRUE) {

  cli::cli_h1("retrieving sovereign cds spreads")

  params <- list(
    "filter[country]" = country,
    "filter[as_of]" = if (is.null(as_of)) NULL else as.character(as.Date(as_of)),
    "page[limit]" = limit,
    "page[offset]" = offset
  )

  df_out <- cached_api_df(
    endpoint = "credit-risk/sovereign/cds-spreads",
    params = params,
    cache_folder = cache_folder,
    cache_prefix = "cds-spreads",
    check_quota = check_quota,
    post_fun = function(df) fix_date_cols(df, c("as_of", "date"))
  )

  cli::cli_alert_success("got {nrow(df_out)} row{?s}")

  return(df_out)

}

#' Retrieves the default spreads by rating
#'
#' Queries the credit risk endpoints of eodhd for the spread over the risk free
#' rate of each rating bucket.
#'
#' @inheritParams get_sovereign_risk_premium
#' @param rating an optional rating (e.g. "Baa2")
#'
#' @return A dataframe with the default spreads
#' @export
#'
#' @examples
#' \dontrun{
#' set_token("YOUR_VALID_TOKEN")
#' df_spreads <- get_default_spreads()
#' }
get_default_spreads <- function(rating = NULL,
                                as_of = NULL,
                                limit = 100,
                                offset = 0,
                                cache_folder = get_default_cache(),
                                check_quota = TRUE) {

  cli::cli_h1("retrieving default spreads")

  params <- list(
    "filter[rating]" = rating,
    "filter[as_of]" = if (is.null(as_of)) NULL else as.character(as.Date(as_of)),
    "page[limit]" = limit,
    "page[offset]" = offset
  )

  df_out <- cached_api_df(
    endpoint = "credit-risk/sovereign/default-spreads",
    params = params,
    cache_folder = cache_folder,
    cache_prefix = "default-spreads",
    check_quota = check_quota,
    post_fun = function(df) fix_date_cols(df, c("as_of", "date"))
  )

  cli::cli_alert_success("got {nrow(df_out)} row{?s}")

  return(df_out)

}

#' Retrieves the corporate market distress index (cmdi)
#'
#' Queries the credit risk endpoints of eodhd for the corporate market distress
#' index, a daily measure of the stress of the corporate bond market.
#'
#' @inheritParams get_fundamentals
#' @param first_date an optional first date of the window
#' @param last_date an optional last date of the window
#' @param limit maximum number of rows (default 100)
#' @param offset pagination offset (default 0)
#'
#' @return A dataframe with the cmdi series
#' @export
#'
#' @examples
#' \dontrun{
#' set_token("YOUR_VALID_TOKEN")
#' df_cmdi <- get_corporate_cmdi()
#' }
get_corporate_cmdi <- function(first_date = NULL,
                               last_date = NULL,
                               limit = 100,
                               offset = 0,
                               cache_folder = get_default_cache(),
                               check_quota = TRUE) {

  cli::cli_h1("retrieving corporate market distress index")

  params <- list(
    "filter[from]" = if (is.null(first_date)) NULL else as.character(as.Date(first_date)),
    "filter[to]" = if (is.null(last_date)) NULL else as.character(as.Date(last_date)),
    "page[limit]" = limit,
    "page[offset]" = offset
  )

  df_out <- cached_api_df(
    endpoint = "credit-risk/corporate/cmdi",
    params = params,
    cache_folder = cache_folder,
    cache_prefix = "corporate-cmdi",
    check_quota = check_quota,
    post_fun = function(df) fix_date_cols(df, "date")
  )

  cli::cli_alert_success("got {nrow(df_out)} row{?s}")

  return(df_out)

}

#' Retrieves the high quality market (hqm) corporate bond yields
#'
#' Queries the credit risk endpoints of eodhd for the hqm corporate yield curve,
#' by tenor.
#'
#' @inheritParams get_corporate_cmdi
#' @param tenor an optional tenor in years (e.g. 10)
#' @param type an optional curve type
#'
#' @return A dataframe with the hqm yields
#' @export
#'
#' @examples
#' \dontrun{
#' set_token("YOUR_VALID_TOKEN")
#' df_hqm <- get_corporate_hqm_yields(tenor = 10)
#' }
get_corporate_hqm_yields <- function(tenor = NULL,
                                     type = NULL,
                                     first_date = NULL,
                                     last_date = NULL,
                                     limit = 100,
                                     offset = 0,
                                     cache_folder = get_default_cache(),
                                     check_quota = TRUE) {

  cli::cli_h1("retrieving hqm corporate yields")

  params <- list(
    "filter[tenor]" = tenor,
    "filter[type]" = type,
    "filter[from]" = if (is.null(first_date)) NULL else as.character(as.Date(first_date)),
    "filter[to]" = if (is.null(last_date)) NULL else as.character(as.Date(last_date)),
    "page[limit]" = limit,
    "page[offset]" = offset
  )

  df_out <- cached_api_df(
    endpoint = "credit-risk/corporate/hqm-yields",
    params = params,
    cache_folder = cache_folder,
    cache_prefix = "hqm-yields",
    check_quota = check_quota,
    post_fun = function(df) fix_date_cols(df, "date")
  )

  cli::cli_alert_success("got {nrow(df_out)} row{?s}")

  return(df_out)

}

#' Retrieves the aggregates of the cds market
#'
#' Queries the credit risk endpoints of eodhd for the aggregated metrics of the
#' credit default swap market, by dimension (sector, region, rating).
#'
#' @inheritParams get_corporate_cmdi
#' @param metric an optional metric to aggregate
#' @param dimension an optional dimension of the aggregation (e.g. "sector")
#' @param value an optional value of the dimension (e.g. "Energy")
#' @param region an optional region
#'
#' @return A dataframe with the cds market aggregates
#' @export
#'
#' @examples
#' \dontrun{
#' set_token("YOUR_VALID_TOKEN")
#' df_agg <- get_cds_market_aggregates()
#' }
get_cds_market_aggregates <- function(metric = NULL,
                                      dimension = NULL,
                                      value = NULL,
                                      region = NULL,
                                      first_date = NULL,
                                      last_date = NULL,
                                      limit = 100,
                                      offset = 0,
                                      cache_folder = get_default_cache(),
                                      check_quota = TRUE) {

  cli::cli_h1("retrieving cds market aggregates")

  params <- list(
    "filter[metric]" = metric,
    "filter[dimension]" = dimension,
    "filter[value]" = value,
    "filter[region]" = region,
    "filter[from]" = if (is.null(first_date)) NULL else as.character(as.Date(first_date)),
    "filter[to]" = if (is.null(last_date)) NULL else as.character(as.Date(last_date)),
    "page[limit]" = limit,
    "page[offset]" = offset
  )

  df_out <- cached_api_df(
    endpoint = "credit-risk/cds-market/aggregates",
    params = params,
    cache_folder = cache_folder,
    cache_prefix = "cds-aggregates",
    check_quota = check_quota,
    post_fun = function(df) fix_date_cols(df, "date")
  )

  cli::cli_alert_success("got {nrow(df_out)} row{?s}")

  return(df_out)

}
