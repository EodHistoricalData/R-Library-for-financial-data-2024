#' Builds a query string and retrieves content from any eodhd endpoint
#'
#' All exported functions of the package go through this one. Parameters with
#' NULL values are dropped, the token is appended and the url is properly
#' encoded (needed for JSON:API style parameters such as "filter\[symbol\]").
#'
#' @param endpoint the endpoint path, without the base url (e.g. "eod/AAPL.US")
#' @param params a named list of query parameters
#'
#' @return the raw content (txt) of the response
#'
#' @noRd
eodhd_content <- function(endpoint, params = list()) {

  token <- get_token()

  params <- params[!purrr::map_lgl(params, is.null)]

  if (!"fmt" %in% names(params)) {
    params[["fmt"]] <- "json"
  }

  params[["api_token"]] <- token

  # get_eodhd() is exported, so the endpoint comes from the caller. It is a path
  # under the base url and nothing else: a full url would be pasted after the
  # base one and silently produce a nonsense request
  if (grepl("^[A-Za-z][A-Za-z0-9+.-]*:", endpoint) || grepl("^//", endpoint)) {
    cli::cli_abort("{.arg endpoint} is a path, not a url: {.val {endpoint}}")
  }

  # the docs print endpoints with a leading slash, and the base url already
  # ends where one is added
  endpoint <- sub("^/+", "", endpoint)

  url <- httr::modify_url(
    paste0(get_base_url(), "/", endpoint),
    query = params
  )

  content <- query_api(url)

  return(content)

}

#' A 32 bit FNV-1a hash of a string
#'
#' Used for building short and unique cache file names out of long parameter
#' sets. Pure base R, so it adds no dependency.
#'
#' @noRd
str_hash <- function(x) {

  h <- 2166136261

  # fnv-1a is defined over bytes. utf8ToInt would give code points, and taking
  # their low byte would map e.g. "A" (U+0041) and "\u0141" to the same value
  for (b in as.integer(charToRaw(enc2utf8(x)))) {
    # only the low byte is xored, so we keep h out of bitwXor (it overflows the
    # integer range of R as soon as the hash passes 2^31)
    low <- h %% 256
    h <- h - low + bitwXor(as.integer(low), b)
    lo <- h %% 65536
    hi <- h %/% 65536
    h <- ((lo * 16777619) + ((hi * 16777619) %% 65536) * 65536) %% 4294967296
  }

  # printed in two halves: %x would coerce h to integer and overflow
  return(sprintf("%04x%04x", h %/% 65536, h %% 65536))

}

#' Builds a readable (and unique) cache file name out of a parameter list
#'
#' @noRd
build_cache_name <- function(prefix, params = list()) {

  params <- params[!purrr::map_lgl(params, is.null)]

  if (length(params) == 0) {
    return(prefix)
  }

  if (is.null(names(params)) || anyNA(names(params)) || any(names(params) == "")) {
    cli::cli_abort("every query parameter needs a name")
  }

  params <- params[order(names(params))]

  # every name and every element is written after its own length, so the string
  # can be read back apart unambiguously and two different parameter sets can
  # never produce the same one. Pasting the parts raw does not have that
  # property: list(c("a_b", "c")) and list(c("a", "b_c")) both read as "a_b_c"
  bits <- paste0(
    nchar(names(params)), ":", names(params), "-",
    purrr::map_chr(params, function(x) {
      x <- as.character(x)
      paste0(length(x), ":", paste0(nchar(x), ":", x, collapse = "_"))
    })
  )

  key <- paste(c(prefix, bits), collapse = "_")

  # the hash is taken before the file name is sanitised, and is always appended:
  # stripping "[", "]" and "/" would otherwise let two different parameter sets
  # (e.g. "filter[year]" and "filteryear") share one cache file
  suffix <- str_hash(key)

  key <- gsub("[^A-Za-z0-9._-]", "", key)

  if (nchar(key) > 100) {
    key <- substr(key, 1, 100)
  }

  return(paste0(key, "-", suffix))

}

#' Path of a cache file for endpoints that are not ticker based
#'
#' @noRd
get_generic_cache_file <- function(cache_folder, name) {

  f_out <- fs::path(cache_folder, glue::glue("{name}_eodhd.rds"))

  fs::dir_create(dirname(f_out), recurse = TRUE)

  return(f_out)

}

#' Parses the content of a response into a tibble
#'
#' Handles the three shapes the api returns: a plain array of objects, a
#' JSON:API document (data/attributes) and a named list of records.
#'
#' @noRd
parse_api_df <- function(content, element = NULL) {

  # httr gives NA_character_ for an empty body, and the api answers "[]" or "{}"
  # when nothing matched
  if (is_empty_body(content)) {
    return(dplyr::tibble())
  }

  l_json <- jsonlite::fromJSON(content, flatten = TRUE)

  if (!is.null(element) && is.list(l_json) && element %in% names(l_json)) {
    l_json <- l_json[[element]]
  } else if (is.list(l_json) && !is.data.frame(l_json) && "data" %in% names(l_json)) {
    l_json <- l_json[["data"]]
  }

  if (is.null(l_json) || length(l_json) == 0) {
    return(dplyr::tibble())
  }

  if (is.data.frame(l_json)) {
    df_out <- dplyr::as_tibble(l_json)
  } else if (is.list(l_json) && is_single_record(l_json)) {
    # a single object (e.g. the live quote of one ticker) is one row
    df_out <- dplyr::as_tibble(purrr::map(l_json, fix_null))
  } else if (is.list(l_json)) {
    df_out <- purrr::map(l_json, ~ dplyr::as_tibble(purrr::map(.x, fix_null))) |>
      purrr::list_rbind()
  } else {
    df_out <- dplyr::tibble(value = l_json)
  }

  df_out <- strip_jsonapi_envelope(df_out)

  return(df_out)

}

#' Drops the JSON:API envelope (type/id/links) and unnests the attributes
#'
#' JSON:API responses arrive as type/id/attributes.*. Keeping both the envelope
#' and the attributes creates duplicated names whenever the payload itself has a
#' field called type or id (the options endpoints do).
#'
#' @noRd
strip_jsonapi_envelope <- function(df_in) {

  idx_attr <- grep("^attributes\\.", names(df_in))

  if (length(idx_attr) == 0) {
    return(df_in)
  }

  df_out <- df_in[, idx_attr, drop = FALSE]
  names(df_out) <- gsub("^attributes\\.", "", names(df_out))

  # the id of the envelope is only kept when the payload has no id of its own
  if ("id" %in% names(df_in) && !"id" %in% names(df_out)) {
    df_out[["id"]] <- df_in[["id"]]
  }

  return(df_out)

}

#' TRUE when a parsed json object is one record, not a collection of records
#'
#' The api returns a single object (named list of scalars) when a query matches
#' one entity, and an array of objects otherwise.
#'
#' @noRd
is_single_record <- function(l_in) {

  nms <- names(l_in)

  if (is.null(nms) || any(nms == "")) {
    return(FALSE)
  }

  all(purrr::map_lgl(l_in, ~ is.null(.x) || (is.atomic(.x) && length(.x) == 1)))

}

#' Retrieves a dataframe from an endpoint, with quota check and local cache
#'
#' @noRd
cached_api_df <- function(endpoint,
                          params = list(),
                          cache_folder = get_default_cache(),
                          cache_prefix = "query",
                          check_quota = TRUE,
                          element = NULL,
                          post_fun = NULL) {

  if (check_quota) {
    get_quota_status()
  }

  f_out <- get_generic_cache_file(
    cache_folder,
    build_cache_name(cache_prefix, params)
  )

  if (fs::file_exists(f_out)) {
    return(read_cache(f_out))
  }

  content <- eodhd_content(endpoint, params)

  df_out <- parse_api_df(content, element = element)

  if (!is.null(post_fun) && nrow(df_out) > 0) {
    df_out <- post_fun(df_out)
  }

  write_cache(df_out, f_out)

  return(df_out)

}

#' Converts date columns to Date, ignoring the ones that are not there
#'
#' @noRd
fix_date_cols <- function(df_in, cols) {

  cols <- intersect(cols, names(df_in))

  if (length(cols) == 0) {
    return(df_in)
  }

  df_in |>
    dplyr::mutate(dplyr::across(dplyr::all_of(cols), as.Date))

}

#' Retrieves data from any eodhd endpoint
#'
#' A low level escape hatch for the endpoints that do not (yet) have a dedicated
#' function in the package. See <https://eodhd.com/financial-apis/> for the full
#' list of endpoints and their parameters. The api token is added for you.
#'
#' @param endpoint the endpoint path, without the base url and without the token
#'  (e.g. "eod/AAPL.US", "real-estate/US", "sanctions/entities")
#' @param params a named list of query parameters (e.g. list(from = "2026-01-01"))
#' @param as_dataframe if TRUE (default) the response is parsed into a dataframe.
#'  Set it to FALSE for endpoints that return a nested object (the raw list is
#'  returned instead).
#' @inheritParams get_fundamentals
#'
#' @return a dataframe (or a list, when as_dataframe = FALSE)
#' @export
#'
#' @examples
#' \dontrun{
#' set_token("YOUR_VALID_TOKEN")
#' df_rates <- get_eodhd("ust/yield-rates", list(`filter[year]` = 2026))
#' }
get_eodhd <- function(endpoint,
                      params = list(),
                      as_dataframe = TRUE,
                      cache_folder = get_default_cache(),
                      check_quota = TRUE) {

  cli::cli_h1("querying endpoint {endpoint}")

  if (check_quota) {
    get_quota_status()
  }

  f_out <- get_generic_cache_file(
    cache_folder,
    build_cache_name(
      # the mode belongs in the key: the same endpoint answers a tibble or a
      # list depending on as_dataframe, and both would land in the same file
      paste0(if (as_dataframe) "raw_df_" else "raw_list_",
             gsub("[^A-Za-z0-9]", "-", endpoint)),
      params
    )
  )

  if (fs::file_exists(f_out)) {
    return(read_cache(f_out))
  }

  content <- eodhd_content(endpoint, params)

  if (as_dataframe) {
    out <- parse_api_df(content)
    cli::cli_alert_success("got {nrow(out)} rows")
  } else {
    if (is_empty_body(content)) {
      out <- list()
    } else {
      out <- jsonlite::fromJSON(content)
    }
    cli::cli_alert_success("got a list with {length(out)} elements")
  }

  write_cache(out, f_out)

  return(out)

}

#' Retrieves the details of the account behind the current token
#'
#' Returns the information of the user api
#' (<https://eodhd.com/financial-apis/user-api>): name, subscription,
#' number of api calls used today and the daily limit.
#'
#' @return a dataframe with one row
#' @export
#'
#' @examples
#' \dontrun{
#' set_token("YOUR_VALID_TOKEN")
#' get_user_info()
#' }
get_user_info <- function() {

  l_user <- get_quota(get_token())

  df_out <- dplyr::as_tibble(purrr::map(l_user, fix_null))

  cli::cli_alert_success(
    "{df_out$apiRequests} of {df_out$dailyRateLimit} api calls used today"
  )

  return(df_out)

}
