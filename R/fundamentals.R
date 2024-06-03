get_fundamentals <- function(ticker = "AAPL",
                             exchange = "US",
                             cache_folder = fs::path_temp("oedhd-cache"),
                             check_quota = TRUE
) {

  cli::cli_h1("fetching fundamentals for ticker {ticker}|{exchange}")

  token <- get_token()

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

    url <- glue::glue('https://eodhd.com/api/fundamentals/{ticker}.{exchange}?api_token={token}&fmt=json')

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

parse_financials <- function(l_out) {

  ticker <- l_out$General$Code
  this_name <- l_out$General$Name
  currency <- l_out$General$CurrencyCode

  cli::cli_h2("Parsing financial data for {this_name} | {ticker}")

  Financials <- l_out$Financials
  names_fin <- names(Financials)

  df_financials <- dplyr::tibble()
  for (i_fin in names_fin) {

    cli::cli_alert_info("parsing {i_fin}  data")
    this_fin <- Financials[[i_fin]]

    currency <- this_fin$currency_symbol

    names_freq <- c("quarterly", "yearly")

    for (i_freq in names_freq) {
      cli::cli_alert_info("\t{i_freq}")

      df_this <- purrr::map_df(this_fin[[i_freq]], parse_single_financial) |>
        dplyr::mutate(ticker = ticker,
                      company_name = this_name,
                      frequency = i_freq,
                      type_financial = i_fin,
                      .after =filing_date)

      df_financials <- dplyr::bind_rows(
        df_financials,
        df_this
      )
    }


  }

  cli::cli_alert_success("got {nrow(df_financials)} rows of financial data")

  return(df_financials)

}


parse_single_financial <- function(x) {

  elements <- purrr::map(x, fix_null)

  elements$date <- as.Date(elements$date)
  elements$filing_date <- as.Date(elements$filing_date)

  non_numeric_cols <- c("date", "filing_date", "currency_symbol")
  numeric_cols <- setdiff(names(elements), non_numeric_cols)

  for (i_name in numeric_cols) {
    elements[[i_name]] <- as.numeric(    elements[[i_name]] )
  }

  df_out <- dplyr::as_tibble(elements)

  return(df_out)
}
