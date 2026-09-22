#' Retrieves news for a given ticker and exchange
#'
#' This function will query the news point of eodhd and return all news for a user
#' supplied time period.
#'
#' @inheritParams get_fundamentals
#' @param first_date the first date to fetch news. The function will keep querying the api
#'  until this date is reached. Default is previous three months.
#' @param last_date the last date to fetch news. Default is today.
#' @param offset_delta how much to change offset in each iterations (higher values will result
#'  in more query time, but less queries). Default is 500.
#'
#' @return A dataframe with news events and sentiments
#' @export
#'
#' @examples
#' \dontrun{
#' set_token(get_demo_token())
#' df_news <- get_news(ticker = "AAPL", exchange = "US")
#' }
get_news <- function(ticker = "AAPL",
                     exchange = "US",
                     first_date = Sys.Date() - 3*30,
                     last_date = Sys.Date(),
                     offset_delta = 500,
                     cache_folder = get_default_cache(),
                     check_quota = TRUE) {

  cli::cli_h1("retrieving news data for ticker {ticker}|{exchange}")

  if (check_quota) {
    get_quota_status()
  }

  token <- get_token()

  first_date <- as.Date(first_date)
  last_date <- as.Date(last_date)

  f_out <-get_cache_file(ticker, exchange, cache_folder,
                         paste0("news_",
                                first_date, '_',
                                last_date))

  if (fs::file_exists(f_out)) {

    df_out <- read_cache(f_out)

    return(df_out)
  }

  i_query <- 1
  this_offset <- 0
  l_news <- list()
  while (TRUE) {
    cli::cli_alert_info("query #{i_query} | offset = {this_offset}")

    url <- glue::glue(
      paste0('{get_base_url()}/news?s=',
             '{ticker}.{exchange}&',
             'from={as.character(first_date)}&',
             'to={as.character(last_date)}&',
             'offset={this_offset}&',
             'limit={offset_delta}&',
             'api_token={token}&fmt=json'
      )
    )

    content <- query_api(url)

    if (is_empty_body(content)) {
      cli::cli_alert_warning("cant find any more data..")
      break()
    }

    this_news <- jsonlite::fromJSON(content)

    # symbols and tags arrive as arrays, and are pasted into one string per news
    if ("symbols" %in% names(this_news)) {
      this_news$symbols <- this_news$symbols |>
        purrr::map_chr(paste0, collapse = ", ")
    }

    if ("tags" %in% names(this_news)) {
      this_news$tags <- this_news$tags |>
        purrr::map_chr(paste0, collapse = ", ")
    }

    # the sentiment is a nested object (neg/neu/pos) -- flatten it into columns
    if ("sentiment" %in% names(this_news)) {
      sentiment <- this_news$sentiment
      this_news$sentiment <- NULL
      names(sentiment) <- paste0("sentiment_", names(sentiment))
      this_news <- dplyr::bind_cols(this_news, dplyr::as_tibble(sentiment))
    }

    this_news <- this_news |>
      dplyr::mutate(
        date = as.POSIXct(date, tz = "UTC"),
        ticker = ticker,
        exchange = exchange
      )

    query_last_date <- max(as.Date(this_news$date))
    n_rows <- nrow(this_news)

    cli::cli_alert_success(
      "\tgot {n_rows} news | last date: {query_last_date}"
      )

    l_news[[i_query]] <- this_news

    i_query <- i_query + 1
    this_offset <- this_offset + offset_delta

    if (query_last_date <= first_date) {
      cli::cli_alert_warning("current date is lower than first date.. exiting loop.")

      break()

    }

  }

  df_news <- l_news |>
    purrr::list_rbind()

  write_cache(df_news, f_out)

  if (nrow(df_news) > 0) {
    cli::cli_alert_success("got {nrow(df_news)} rows of news from {min(df_news$date)} to {max(df_news$date)}")
  } else {
    cli::cli_alert_danger("cant find news for {ticker}|{exchange} between {first_date} and {last_date}")
  }

  return(df_news)

}

