#' Retrieves the daily news sentiment of one or more tickers
#'
#' Queries the sentiment endpoint
#' <https://eodhd.com/financial-apis/stock-market-financial-news-api>, which
#' aggregates, by day, the number of news articles of a ticker and their
#' normalised sentiment (from -1 to 1).
#'
#' @inheritParams get_fundamentals
#' @param symbols a character vector of tickers with exchange
#'  (e.g. c("AAPL.US", "BTC-USD.CC"))
#' @param first_date the first date of the window. Default is 30 days ago.
#' @param last_date the last date of the window. Default is today.
#'
#' @return A dataframe with columns symbol, date, count and normalized
#' @export
#'
#' @examples
#' \dontrun{
#' set_token("YOUR_VALID_TOKEN")
#' df_sentiment <- get_sentiments("AAPL.US")
#' }
get_sentiments <- function(symbols = "AAPL.US",
                           first_date = Sys.Date() - 30,
                           last_date = Sys.Date(),
                           cache_folder = get_default_cache(),
                           check_quota = TRUE) {

  cli::cli_h1("retrieving news sentiment for {symbols}")

  if (check_quota) {
    get_quota_status()
  }

  params <- list(
    s = paste0(symbols, collapse = ","),
    from = as.character(as.Date(first_date)),
    to = as.character(as.Date(last_date))
  )

  f_out <- get_generic_cache_file(
    cache_folder,
    build_cache_name("sentiments", params)
  )

  if (fs::file_exists(f_out)) {
    return(read_cache(f_out))
  }

  content <- eodhd_content("sentiments", params)

  if (is_empty_body(content)) {
    l_json <- list()
  } else {
    l_json <- jsonlite::fromJSON(content, flatten = TRUE)
  }

  df_out <- purrr::imap(
    l_json,
    function(x, symbol) {
      if (length(x) == 0) return(dplyr::tibble())
      dplyr::as_tibble(x) |>
        dplyr::mutate(symbol = symbol, .before = 1)
    }
  ) |>
    purrr::list_rbind()

  if (nrow(df_out) > 0) {
    df_out <- fix_date_cols(df_out, "date")
  }

  write_cache(df_out, f_out)

  cli::cli_alert_success("got {nrow(df_out)} row{?s} of sentiment data")

  return(df_out)

}

#' Retrieves the most relevant words of the news of a ticker
#'
#' Queries the news word weights endpoint of eodhd, which returns the keywords of
#' the news of a ticker with their weight.
#'
#' @inheritParams get_fundamentals
#' @param first_date an optional first date of the window
#' @param last_date an optional last date of the window
#' @param limit maximum number of words (default 50)
#'
#' @return A dataframe with columns word and weight
#' @export
#'
#' @examples
#' \dontrun{
#' set_token("YOUR_VALID_TOKEN")
#' df_words <- get_news_word_weights("AAPL", "US")
#' }
get_news_word_weights <- function(ticker = "AAPL",
                                  exchange = "US",
                                  first_date = NULL,
                                  last_date = NULL,
                                  limit = 50,
                                  cache_folder = get_default_cache(),
                                  check_quota = TRUE) {

  cli::cli_h1("retrieving news word weights for {ticker}|{exchange}")

  if (check_quota) {
    get_quota_status()
  }

  params <- list(
    s = glue::glue("{ticker}.{exchange}"),
    "filter[date_from]" = if (is.null(first_date)) NULL else as.character(as.Date(first_date)),
    "filter[date_to]" = if (is.null(last_date)) NULL else as.character(as.Date(last_date)),
    "page[limit]" = limit
  )

  f_out <- get_generic_cache_file(
    cache_folder,
    build_cache_name("news-word-weights", params)
  )

  if (fs::file_exists(f_out)) {
    return(read_cache(f_out))
  }

  content <- eodhd_content("news-word-weights", params)

  if (is_empty_body(content)) {
    l_json <- list()
  } else {
    l_json <- jsonlite::fromJSON(content)
  }

  if (is.null(l_json$data)) {
    df_out <- dplyr::tibble(word = character(), weight = numeric())
  } else {
    df_out <- dplyr::tibble(
      word = names(l_json$data),
      weight = as.numeric(unlist(l_json$data))
    )
  }

  write_cache(df_out, f_out)

  cli::cli_alert_success("got {nrow(df_out)} word{?s}")

  return(df_out)

}
