#' Retrieves the countries covered by the real estate data
#'
#' Queries the real estate endpoints of eodhd, which serve house price indices
#' and rent series by country and region.
#'
#' @inheritParams get_fundamentals
#' @param sort an optional sort expression (e.g. "code")
#' @param limit maximum number of rows (default 100)
#' @param offset pagination offset (default 0)
#'
#' @return A dataframe with the available countries
#' @export
#'
#' @examples
#' \dontrun{
#' set_token("YOUR_VALID_TOKEN")
#' df_countries <- get_real_estate_countries()
#' }
get_real_estate_countries <- function(sort = NULL,
                                      limit = 100,
                                      offset = 0,
                                      cache_folder = get_default_cache(),
                                      check_quota = TRUE) {

  cli::cli_h1("retrieving real estate countries")

  params <- list(
    sort = sort,
    "page[limit]" = limit,
    "page[offset]" = offset
  )

  df_out <- cached_api_df(
    endpoint = "real-estate/countries",
    params = params,
    cache_folder = cache_folder,
    cache_prefix = "real-estate-countries",
    check_quota = check_quota
  )

  cli::cli_alert_success("got {nrow(df_out)} countr{?y/ies}")

  return(df_out)

}

#' Retrieves the real estate series of a country
#'
#' Queries the real estate endpoints of eodhd for the headline indices of a
#' country (house prices, rents and their real counterparts).
#'
#' @inheritParams get_real_estate_countries
#' @param code the country code (e.g. "US"). See [eodhdR2::get_real_estate_countries()].
#' @param type an optional type of series
#' @param metric an optional metric
#' @param first_date an optional first date of the window
#' @param last_date an optional last date of the window
#'
#' @return A dataframe with the real estate series
#' @export
#'
#' @examples
#' \dontrun{
#' set_token("YOUR_VALID_TOKEN")
#' df_re <- get_real_estate("US")
#' }
get_real_estate <- function(code = "US",
                            type = NULL,
                            metric = NULL,
                            first_date = NULL,
                            last_date = NULL,
                            sort = NULL,
                            limit = 100,
                            offset = 0,
                            cache_folder = get_default_cache(),
                            check_quota = TRUE) {

  cli::cli_h1("retrieving real estate data for {code}")

  params <- list(
    "filter[type]" = type,
    "filter[metric]" = metric,
    "filter[from]" = if (is.null(first_date)) NULL else as.character(as.Date(first_date)),
    "filter[to]" = if (is.null(last_date)) NULL else as.character(as.Date(last_date)),
    sort = sort,
    "page[limit]" = limit,
    "page[offset]" = offset
  )

  df_out <- cached_api_df(
    endpoint = glue::glue("real-estate/{code}"),
    params = params,
    cache_folder = cache_folder,
    cache_prefix = glue::glue("real-estate-{code}"),
    check_quota = check_quota,
    post_fun = function(df) fix_date_cols(df, "date")
  )

  cli::cli_alert_success("got {nrow(df_out)} row{?s}")

  return(df_out)

}

#' Retrieves the detailed real estate series of a country
#'
#' Queries the detailed real estate endpoint of eodhd, which breaks the series of
#' a country by area, property type and vintage.
#'
#' @inheritParams get_real_estate
#' @param area an optional area (e.g. a metropolitan area)
#' @param property_type an optional property type
#' @param vintage an optional vintage of the series
#' @param freq an optional frequency of the series
#'
#' @return A dataframe with the detailed real estate series
#' @export
#'
#' @examples
#' \dontrun{
#' set_token("YOUR_VALID_TOKEN")
#' df_re <- get_real_estate_detailed("US")
#' }
get_real_estate_detailed <- function(code = "US",
                                     area = NULL,
                                     property_type = NULL,
                                     vintage = NULL,
                                     freq = NULL,
                                     first_date = NULL,
                                     last_date = NULL,
                                     sort = NULL,
                                     limit = 100,
                                     offset = 0,
                                     cache_folder = get_default_cache(),
                                     check_quota = TRUE) {

  cli::cli_h1("retrieving detailed real estate data for {code}")

  params <- list(
    "filter[area]" = area,
    "filter[property_type]" = property_type,
    "filter[vintage]" = vintage,
    "filter[freq]" = freq,
    "filter[from]" = if (is.null(first_date)) NULL else as.character(as.Date(first_date)),
    "filter[to]" = if (is.null(last_date)) NULL else as.character(as.Date(last_date)),
    sort = sort,
    "page[limit]" = limit,
    "page[offset]" = offset
  )

  df_out <- cached_api_df(
    endpoint = glue::glue("real-estate/{code}/detailed"),
    params = params,
    cache_folder = cache_folder,
    cache_prefix = glue::glue("real-estate-detailed-{code}"),
    check_quota = check_quota,
    post_fun = function(df) fix_date_cols(df, "date")
  )

  cli::cli_alert_success("got {nrow(df_out)} row{?s}")

  return(df_out)

}

#' Retrieves the catalog of detailed real estate series of a country
#'
#' Lists the series available at [eodhdR2::get_real_estate_detailed()] for a
#' country, with their area, property type and vintage.
#'
#' @inheritParams get_real_estate
#'
#' @return A dataframe with the available series
#' @export
#'
#' @examples
#' \dontrun{
#' set_token("YOUR_VALID_TOKEN")
#' df_series <- get_real_estate_series("US")
#' }
get_real_estate_series <- function(code = "US",
                                   cache_folder = get_default_cache(),
                                   check_quota = TRUE) {

  cli::cli_h1("retrieving real estate series of {code}")

  df_out <- cached_api_df(
    endpoint = glue::glue("real-estate/{code}/detailed/series"),
    params = list(),
    cache_folder = cache_folder,
    cache_prefix = glue::glue("real-estate-series-{code}"),
    check_quota = check_quota
  )

  cli::cli_alert_success("got {nrow(df_out)} series")

  return(df_out)

}
