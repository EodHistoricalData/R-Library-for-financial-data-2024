#' Get Index Composition
#'
#' Retrieves the current and historical components of a financial index
#' from the EODHD API. Uses a caching system to avoid redundant API calls.
#
#' @param index index to find composition (e.g. "GSPC.INDX")
#' @inheritParams get_fundamentals
#'
#' @returns a list with three elements: info, current_components, historical_components
#' @export
#'
#' @examples
#'
#' \dontrun{
#' l_out <- get_index_composition("GSPC.INDX")
#' str(l_out)
#' }
get_index_composition <- function(index, cache_folder = get_default_cache()) {

  token <- get_token()

  cli::cli_h1("retrieving index composition for {index}")

  f_out <-get_cache_file(index, "", cache_folder, "index-composition")

  if (fs::file_exists(f_out)) {

    l_out <- read_cache(f_out)

    return(l_out)

  } else {

    url <- glue::glue(
      "{get_base_url()}/fundamentals/{index}?api_token={token}&fmt=json"
    )

    content <- query_api(url)

    if (is_empty_body(content)) {
      l_json <- list()
    } else {
      l_json <- jsonlite::fromJSON(content)
    }

    info <- l_json$General |>
      purrr::map(fix_elements) |>
      dplyr::as_tibble()

    current_components <- l_json$Components |>
      purrr::map(list_to_tibble) |>
      purrr::list_rbind() |>
      dplyr::as_tibble()

    # not every index carries a component history
    historical_components <- l_json$HistoricalTickerComponents |>
      purrr::map(list_to_tibble) |>
      purrr::list_rbind() |>
      dplyr::as_tibble() |>
      fix_date_cols(c("StartDate", "EndDate"))

    l_out <- list(
      info = info,
      current_components = current_components,
      historical_components = historical_components
    )

    write_cache(l_out, f_out)

  }

  cli::cli_alert_success("got list with {length(l_out)} elements")

  return(l_out)

}

fix_elements <- function(x) {
  if (is.null(x)) {
    return(NA)
  } else {
    return(x)
  }

}

list_to_tibble <- function(l_in) {

  l_fixed <- purrr::map(
    l_in, fix_elements
  )

  df_out <- dplyr::as_tibble(l_fixed)

  return(df_out)

}

#' Retrieves the list of indices with composition data
#'
#' Queries the S&P Global data of the eodhd marketplace and returns the indices
#' that have components available for [eodhdR2::get_index_composition()].
#'
#' @inheritParams get_fundamentals
#'
#' @return A dataframe with the available indices
#' @export
#'
#' @examples
#' \dontrun{
#' set_token("YOUR_VALID_TOKEN")
#' df_indices <- get_index_list()
#' }
get_index_list <- function(cache_folder = get_default_cache(),
                           check_quota = TRUE) {

  cli::cli_h1("retrieving list of indices")

  df_out <- cached_api_df(
    endpoint = "mp/unicornbay/spglobal/list",
    params = list(),
    cache_folder = cache_folder,
    cache_prefix = "index-list",
    check_quota = check_quota
  )

  cli::cli_alert_success("got {nrow(df_out)} index{?es}")

  return(df_out)

}
