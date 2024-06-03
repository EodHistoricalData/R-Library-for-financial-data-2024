#' Fetches fundamental data from eodhd api
#'
#' @param ticker a company ticker (identificer) (e.g. AAPL)
#' @param exchange a exchange (e.g. US). You can find all tickers and exchanges from get_info()
#' @param cache_folder A local directory to store cache files. By default, it uses a temporary path, meaning that the cache system
#' is session persistent (it will remove all files when you exit your R session). If you want a persistent caching system, simply
#' point to a local directory in your file system.
#' @param check_quota A flag (TRUE/FALSE) for wheter to check the quote from api or not (a small trade of execution time)
#'
#' @return  a list with several information
#' @export
#'
#' @examples
#' set_token("demo")
#' l_out <- get_fundamentals(ticker = "AAPL", exchange = "US")
#' names(l_out)
get_fundamentals <- function(ticker = "AAPL",
                             exchange = "US",
                             cache_folder = fs::path_temp("oedhd-cache"),
                             check_quota = TRUE
) {

  cli::cli_h1("fetching fundamentals for ticker {ticker}|{exchange}")

  token <- get_token()
  set_token(token)

  if (check_quota) {
    my_quota <- get_quota(token)
    default_tz <- "GMT"

    time_refresh <- lubridate::ymd_hms(paste0(Sys.Date()+1, " 00:00:00"),
                                       tz = default_tz)

    hours_to_renew <- - as.numeric(
      lubridate::now(default_tz) - time_refresh
    )

    cli::cli_alert_warning('Quota status: {my_quota$apiRequests}|{my_quota$dailyRateLimit}, refreshing in {format(hours_to_renew, digits =3)} hours')

    if (my_quota$apiRequests + 10 >= my_quota$dailyRateLimit) {
      cli::cli_abort("ABORT: reached max number of daily requests -- {my_quota$apiRequests}/{my_quota$dailyRateLimit} -- need to wait for refresh")
    }
  }


  f_out <- fs::path(
    cache_folder,
    glue::glue("{ticker}_{exchange}_eod-fundamentals.rds")
  )

  fs::dir_create(dirname(f_out), recurse = TRUE)

  if (fs::file_exists(f_out)) {
    cli::cli_alert_success("\treading cache file {f_out}")

    l_out <- readr::read_rds(f_out)

  } else {

    cli::cli_alert_success("\tquerying API")

    url <- glue::glue('{get_base_url()}/fundamentals/{ticker}.{exchange}?api_token={token}&fmt=json')

    response <- httr::GET(url)

    parse_status_code(response$status_code)

    content <- httr::content(response,
                             "text",
                             encoding = "UTF-8")

    l_out <- jsonlite::fromJSON(content)
    readr::write_rds(l_out, f_out)
  }

  cli::cli_alert_success("\tgot {length(l_out)} elements in list")

  return(l_out)

}
