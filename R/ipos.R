#' Retrieves IPO (Initial Public Offering) data for a given time period
#'
#' This function will query the IPO end point of eodhd and return all ipos for a user
#' supplied time period.
#'
#' @inheritParams get_fundamentals
#' @param first_date the first date to fetch ipos information. Default is previous
#'  three years
#' @param last_date the last date to fetch news. Default is today.
#'
#' @return A dataframe with news events and sentiments
#' @export
#'
#' @examples
#' \dontrun{
#' set_token("YOUR_VALID_TOKEN")
#' df_news <- get_ipos()
#' }
get_ipos <- function(first_date = Sys.Date() - 3*365,
                     last_date = Sys.Date(),
                     cache_folder = get_default_cache(),
                     check_quota = TRUE) {

  cli::cli_h1("retrieving ipo data")

  if (check_quota) {
    get_quota_status()
  }

  token <- get_token()

  first_date <- as.Date(first_date)
  last_date <- as.Date(last_date)

  f_out <- get_cache_file("", "",
                          cache_folder,
                          paste0("ipos_",
                                 first_date, '_',
                                 last_date))

  if (fs::file_exists(f_out)) {

    df_out <- read_cache(f_out)

    return(df_out)
  }

  url <- glue::glue(
    paste0('{get_base_url()}/calendar/ipos?',
           'from={as.character(first_date)}&',
           'to={as.character(last_date)}&',
           'api_token={token}&fmt=json'
    )
  )

  content <- query_api(url)

  if (content == "[]") {
    cli::cli_abort("cant find ipo data for given dates.")
  }

  ipos <- jsonlite::fromJSON(content)$ipos

  ipos <- ipos |>
    dplyr::mutate(
      dplyr::across(dplyr::contains('_date'), as.Date)
    ) |>
    unique()

  write_cache(ipos, f_out)

  cli::cli_alert_success("got {nrow(ipos)} rows of ipos")

  return(ipos)

}
