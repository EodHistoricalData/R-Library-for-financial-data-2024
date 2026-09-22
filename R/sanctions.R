#' Retrieves sanctioned entities
#'
#' Queries the sanctions endpoints of eodhd, which consolidate the lists of the
#' main sanctioning bodies (OFAC, EU, UK and others).
#'
#' @inheritParams get_fundamentals
#' @param source an optional source of the list (see [eodhdR2::get_sanctions_sources()])
#' @param type an optional type of entity (e.g. "individual", "entity")
#' @param program an optional sanction program (see [eodhdR2::get_sanctions_programs()])
#' @param country an optional country code
#' @param query an optional free text search
#' @param active an optional flag (TRUE/FALSE) to keep only the active records
#' @param limit maximum number of rows (default 100)
#' @param offset pagination offset (default 0)
#'
#' @return A dataframe with the sanctioned entities
#' @export
#'
#' @examples
#' \dontrun{
#' set_token("YOUR_VALID_TOKEN")
#' df_entities <- get_sanctions_entities(country = "RU", limit = 10)
#' }
get_sanctions_entities <- function(source = NULL,
                                   type = NULL,
                                   program = NULL,
                                   country = NULL,
                                   query = NULL,
                                   active = NULL,
                                   limit = 100,
                                   offset = 0,
                                   cache_folder = get_default_cache(),
                                   check_quota = TRUE) {

  cli::cli_h1("retrieving sanctioned entities")

  params <- list(
    source = source,
    type = type,
    program = program,
    country = country,
    q = query,
    active = if (is.null(active)) NULL else tolower(as.character(active)),
    "page[limit]" = limit,
    "page[offset]" = offset
  )

  df_out <- cached_api_df(
    endpoint = "sanctions/entities",
    params = params,
    cache_folder = cache_folder,
    cache_prefix = "sanctions-entities",
    check_quota = check_quota
  )

  cli::cli_alert_success("got {nrow(df_out)} entit{?y/ies}")

  return(df_out)

}

#' Retrieves sanctioned vessels
#'
#' Queries the sanctions endpoints of eodhd for the vessels of the consolidated
#' lists, searchable by IMO number and flag.
#'
#' @inheritParams get_sanctions_entities
#' @param imo an optional IMO number of the vessel
#' @param flag an optional flag (country) of the vessel
#' @param vessel_type an optional type of vessel
#'
#' @return A dataframe with the sanctioned vessels
#' @export
#'
#' @examples
#' \dontrun{
#' set_token("YOUR_VALID_TOKEN")
#' df_vessels <- get_sanctions_vessels(limit = 10)
#' }
get_sanctions_vessels <- function(source = NULL,
                                  imo = NULL,
                                  flag = NULL,
                                  vessel_type = NULL,
                                  query = NULL,
                                  program = NULL,
                                  limit = 100,
                                  offset = 0,
                                  cache_folder = get_default_cache(),
                                  check_quota = TRUE) {

  cli::cli_h1("retrieving sanctioned vessels")

  params <- list(
    source = source,
    imo = imo,
    flag = flag,
    vessel_type = vessel_type,
    q = query,
    program = program,
    "page[limit]" = limit,
    "page[offset]" = offset
  )

  df_out <- cached_api_df(
    endpoint = "sanctions/vessels",
    params = params,
    cache_folder = cache_folder,
    cache_prefix = "sanctions-vessels",
    check_quota = check_quota
  )

  cli::cli_alert_success("got {nrow(df_out)} vessel{?s}")

  return(df_out)

}

#' Retrieves the sanction programs
#'
#' Lists the programs that can be used to filter [eodhdR2::get_sanctions_entities()].
#'
#' @inheritParams get_fundamentals
#'
#' @return A dataframe with the sanction programs
#' @export
#'
#' @examples
#' \dontrun{
#' set_token("YOUR_VALID_TOKEN")
#' df_programs <- get_sanctions_programs()
#' }
get_sanctions_programs <- function(cache_folder = get_default_cache(),
                                   check_quota = TRUE) {

  cli::cli_h1("retrieving sanction programs")

  df_out <- cached_api_df(
    endpoint = "sanctions/programs",
    params = list(),
    cache_folder = cache_folder,
    cache_prefix = "sanctions-programs",
    check_quota = check_quota
  )

  cli::cli_alert_success("got {nrow(df_out)} program{?s}")

  return(df_out)

}

#' Retrieves the sources of the sanction lists
#'
#' Lists the sanctioning bodies behind the consolidated data, with the date of
#' their last update.
#'
#' @inheritParams get_fundamentals
#'
#' @return A dataframe with the sources
#' @export
#'
#' @examples
#' \dontrun{
#' set_token("YOUR_VALID_TOKEN")
#' df_sources <- get_sanctions_sources()
#' }
get_sanctions_sources <- function(cache_folder = get_default_cache(),
                                  check_quota = TRUE) {

  cli::cli_h1("retrieving sanction sources")

  df_out <- cached_api_df(
    endpoint = "sanctions/sources",
    params = list(),
    cache_folder = cache_folder,
    cache_prefix = "sanctions-sources",
    check_quota = check_quota
  )

  cli::cli_alert_success("got {nrow(df_out)} source{?s}")

  return(df_out)

}
