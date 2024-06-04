#' Returns quota from eodhd
#'
#' @param token token from website
#'
#' @noRd
get_quota <- function(token = get_demo_token()) {

  url <- glue::glue('{get_base_url()}/user?api_token={token}')

  content <- query_api(url)

  json_data <- jsonlite::fromJSON(content)

  return(json_data)

}

#' Returns a message for quota status
#'
#' @noRd
get_quota_status <- function() {

  token <- get_token()
  my_quota <- get_quota(token)

  # quota refreshes at 00:00:00 GMT
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

  return(invisible(TRUE))
}
