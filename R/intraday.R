#' Retrieves instraday data for a given ticker and exchange
#'
#' This function will query the intraday endpoint of eodhd and return all data for a user
#' supplied time period.
#'
#' @inheritParams get_fundamentals
#' @param frequency The frequency of the intraday data. Available options: "1m"= 1 minute, "5m" = 5 minutes, "1h" = 1 hour
#' @param first_date the first date to fetch news. The function will keep querying the api
#'  until this date is reached. Default is previous week.
#' @param last_date the last date to fetch news. Default is today.
#'
#' @return A dataframe with news events and sentiments
#' @export
#'
#' @examples
#' \dontrun{
#' set_token(get_demo_token())
#' df_intraday <- get_intraday(ticker = "AAPL", exchange = "US")
#' }
get_intraday <- function(ticker = "AAPL",
                     exchange = "US",
                     frequency = "5m",
                     first_date = Sys.Date() - 7,
                     last_date = Sys.Date(),
                     cache_folder = get_default_cache(),
                     check_quota = TRUE) {

  cli::cli_h1("retrieving intraday data for ticker {ticker}|{exchange}")

  if (check_quota) {
    get_quota_status()
  }

  token <- get_token()

  possible_freq <- c("1m", "5m", "1h")
  if (!frequency %in% possible_freq) {
    cli::cli_abort("value of {frequency} is not available in possible values: {possible_freq}")
  }

  # from website https://eodhd.com/financial-apis/intraday-historical-data-api
  offset_delta = switch (
    frequency,
    "1m" = 120, # days
    "5m" = 600,
    "1h" = 7200 # original is 7200
  )

  # get lower rate than limit for avoiding too much ping
  offset_delta <- as.integer(offset_delta*0.75)

  last_time <- as.POSIXlt(
    paste0(last_date, " 23:59:59 UTC"),
    tz = "GMT"
    )

  first_time <- as.POSIXlt(
    paste0(last_date - lubridate::days(offset_delta),
           " 00:00:01"),
    tz = "GMT"
  )

  f_out <-get_cache_file(ticker, exchange, cache_folder,
                         paste0("intraday_",
                                frequency, "_",
                                first_date, '_',
                                last_date))

  if (fs::file_exists(f_out)) {

    df_out <- read_cache(f_out)

    return(df_out)
  }

  i_query <- 1
  l_intraday <- list()
  while (TRUE) {

    if (i_query == 1) {
      cli::cli_alert_info("query #{i_query}")
      this_first_time = first_time
      this_last_time = last_time

    } else {
      cli::cli_alert_info("query #{i_query} | offset = {offset_delta} days")

      this_first_time = this_first_time - lubridate::days(offset_delta)
      this_last_time = this_last_time -  lubridate::days(offset_delta)

    }

    url <- glue::glue(
      paste0('{get_base_url()}intraday/',
             '{ticker}.{exchange}?',
             'api_token={token}&',
             'from={as.numeric(this_first_time)}&',
             'to={as.numeric(this_last_time)}&',
             'fmt=json&',
             'interval={frequency}'
      )
    )

    content <- query_api(url)

    if (content == "[]") {
      cli::cli_alert_warning("cant find any more data.. exiting loop")
      break()
    }

    this_intraday <- jsonlite::fromJSON(content) |>
      dplyr::mutate(
        ticker = ticker,
        exchange = exchange
      )

    this_intraday$datetime <- lubridate::ymd_hms(this_intraday$datetime, tz = "GMT")
    query_first_date <- min(as.Date(this_intraday$datetime))

    n_rows <- nrow(this_intraday)

    cli::cli_alert_success(
      "\t{this_first_time} --> {this_last_time} | got {n_rows} rows"
    )

    i_query <- i_query + 1

    # return only unique data
    this_intraday <- unique(this_intraday)

    l_intraday[[i_query]] <- this_intraday

    if (query_first_date <= first_date) {
      cli::cli_alert_warning("current date is lower than first date.. exiting loop.")

      break()

    }

  }

  df_intraday <- l_intraday |>
    purrr::list_rbind()

  write_cache(df_intraday, f_out)

  cli::cli_alert_success("got {nrow(df_intraday)} rows of intraday data from {min(df_intraday$datetime)} to {max(df_intraday$datetime)}")

  return(df_intraday)

}

