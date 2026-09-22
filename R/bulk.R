#' Retrieves the fundamentals of a whole exchange
#'
#' Queries the bulk fundamentals endpoint
#' <https://eodhd.com/financial-apis/bulk-api-eod-splits-dividends>, which returns
#' the fundamental data of many companies in a single call. Mind the cost: each
#' company of the response is charged as a fundamentals call.
#'
#' @inheritParams get_fundamentals
#' @param exchange the exchange code (e.g. "US")
#' @param symbols an optional character vector of tickers (e.g. c("AAPL", "MSFT")).
#'  Default (NULL) returns the companies of the page.
#' @param limit number of companies of the page (default 10, maximum 1000)
#' @param offset pagination offset (default 0)
#'
#' @return A named list, one element per company, in the same shape as
#'  [eodhdR2::get_fundamentals()]
#' @export
#'
#' @examples
#' \dontrun{
#' set_token("YOUR_VALID_TOKEN")
#' l_bulk <- get_bulk_fundamentals("US", symbols = c("AAPL", "MSFT"))
#' }
get_bulk_fundamentals <- function(exchange = "US",
                                  symbols = NULL,
                                  limit = 10,
                                  offset = 0,
                                  cache_folder = get_default_cache(),
                                  check_quota = TRUE) {

  cli::cli_h1("retrieving bulk fundamentals for exchange {exchange}")

  if (check_quota) {
    get_quota_status()
  }

  params <- list(
    symbols = if (is.null(symbols)) NULL else paste0(symbols, collapse = ","),
    limit = limit,
    offset = offset
  )

  f_out <- get_generic_cache_file(
    cache_folder,
    build_cache_name(glue::glue("bulk-fundamentals-{exchange}"), params)
  )

  if (fs::file_exists(f_out)) {
    return(read_cache(f_out))
  }

  content <- eodhd_content(glue::glue("bulk-fundamentals/{exchange}"), params)

  l_json <- jsonlite::fromJSON(content, simplifyVector = FALSE)

  # the api indexes the companies by position ("0", "1", ...) -- name them by code
  l_out <- l_json[!names(l_json) %in% c("offset", "limit", "count")]

  codes <- purrr::map_chr(
    l_out,
    function(x) {
      code <- x[["General"]][["Code"]]
      if (is.null(code)) NA_character_ else code
    }
  )

  if (!anyNA(codes)) {
    names(l_out) <- codes
  }

  write_cache(l_out, f_out)

  cli::cli_alert_success("got fundamentals of {length(l_out)} compan{?y/ies}")

  return(l_out)

}
