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
      "https://eodhd.com/api/fundamentals/{index}?api_token={token}"
    )

    l_json <- jsonlite::fromJSON(url)

    info <- l_json$General |>
      purrr::map(fix_elements) |>
      dplyr::as_tibble()

    current_components <- l_json$Components |>
      purrr::map(list_to_tibble) |>
      purrr::list_rbind()

    historical_components <- l_json$HistoricalTickerComponents |>
      purrr::map(list_to_tibble) |>
      purrr::list_rbind()

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
