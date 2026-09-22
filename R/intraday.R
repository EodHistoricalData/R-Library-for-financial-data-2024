#' Retrieves intraday data for a given ticker and exchange
#'
#' This function will query the intraday endpoint of eodhd
#' <https://eodhd.com/financial-apis/intraday-historical-data-api> and return all
#' bars available within a user supplied time period. Since the api limits how far
#' back a single query can reach, the function walks backwards in time, querying
#' consecutive windows until the first date is covered.
#'
#' @inheritParams get_fundamentals
#' @param frequency The frequency of the intraday data. Available options: "1m"= 1 minute, "5m" = 5 minutes, "1h" = 1 hour
#' @param first_date the first date of the query window. The function will keep querying the api
#'  until this date is reached. Default is previous week.
#' @param last_date the last date of the query window. Default is today.
#'
#' @return A dataframe with intraday prices (datetime, open, high, low, close, volume)
#' @export
#'
#' @examples
#' \dontrun{
#' set_token(get_demo_token())
#' df_intraday <- get_intraday(ticker = "AAPL", exchange = "US")
#' }
get_intraday <- function(
    ticker = "AAPL",
    exchange = "US",
    frequency = "5m",
    first_date = Sys.Date() - 7,
    last_date = Sys.Date(),
    cache_folder = get_default_cache(),
    check_quota = TRUE
    ) {

  cli::cli_h1("retrieving intraday data for ticker {ticker}|{exchange}")

  if (check_quota) {
    get_quota_status()
  }

  token <- get_token()

  possible_freq <- c("1m", "5m", "1h")
  if (!frequency %in% possible_freq) {
    cli::cli_abort("value of {frequency} is not available in possible values: {possible_freq}")
  }

  first_date <- as.Date(first_date)
  last_date <- as.Date(last_date)

  if (first_date > last_date) {
    cli::cli_abort("first_date ({first_date}) is higher than last_date ({last_date})")
  }

  # maximum span of a single query, from
  # https://eodhd.com/financial-apis/intraday-historical-data-api
  offset_delta = switch (
    frequency,
    "1m" = 120, # days
    "5m" = 600,
    "1h" = 7200 # original is 7200
  )

  # get lower rate than limit for avoiding too much ping
  offset_delta <- as.integer(offset_delta*0.75)

  f_out <-get_cache_file(ticker, exchange, cache_folder,
                         paste0("intraday_",
                                frequency, "_",
                                first_date, '_',
                                last_date))

  if (fs::file_exists(f_out)) {

    df_out <- read_cache(f_out)

    return(df_out)
  }

  target_first_time <- as.POSIXct(paste0(first_date, " 00:00:00"), tz = "GMT")
  target_last_time <- as.POSIXct(paste0(last_date, " 23:59:59"), tz = "GMT")

  # the first window never reaches further back than first_date
  this_last_time <- target_last_time
  this_first_time <- max(
    target_first_time,
    this_last_time - lubridate::days(offset_delta)
  )

  i_query <- 1
  l_intraday <- list()
  while (TRUE) {

    cli::cli_alert_info(
      "query #{i_query} | {as.Date(this_first_time)} --> {as.Date(this_last_time)}"
      )

    url <- glue::glue(
      paste0('{get_base_url()}/intraday/',
             '{ticker}.{exchange}?',
             'api_token={token}&',
             'from={as.numeric(this_first_time)}&',
             'to={as.numeric(this_last_time)}&',
             'fmt=json&',
             'interval={frequency}'
      )
    )

    content <- query_api(url)

    # an empty body arrives as NA, and a window with no bars as "[]"
    if (is_empty_body(content)) {
      cli::cli_alert_warning("\tno data in this window")
    } else {

      this_intraday <- jsonlite::fromJSON(content) |>
        dplyr::mutate(
          ticker = ticker,
          exchange = exchange
        )

      this_intraday$datetime <- lubridate::ymd_hms(this_intraday$datetime, tz = "GMT")

      cli::cli_alert_success("\tgot {nrow(this_intraday)} rows")

      l_intraday[[i_query]] <- unique(this_intraday)
    }

    if (this_first_time <= target_first_time) {
      break()
    }

    this_last_time <- this_first_time - 1
    this_first_time <- max(
      target_first_time,
      this_last_time - lubridate::days(offset_delta)
    )
    i_query <- i_query + 1

  }

  # every window can come back empty, and list_rbind() of an empty list gives a
  # zero column data frame rather than a tibble
  if (length(l_intraday) == 0) {
    df_intraday <- dplyr::tibble()
  } else {
    df_intraday <- purrr::list_rbind(l_intraday)
  }

  if (nrow(df_intraday) > 0) {
    df_intraday <- df_intraday |>
      dplyr::filter(
        datetime >= target_first_time,
        datetime <= target_last_time
      ) |>
      unique() |>
      dplyr::arrange(datetime)
  }

  write_cache(df_intraday, f_out)

  if (nrow(df_intraday) == 0) {
    cli::cli_alert_danger("cant find intraday data for {ticker}|{exchange} between {first_date} and {last_date}")
  } else {
    cli::cli_alert_success("got {nrow(df_intraday)} rows of intraday data from {min(df_intraday$datetime)} to {max(df_intraday$datetime)}")
  }

  return(df_intraday)

}
