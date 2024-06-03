
get_splits <- function(ticker, exchange, token, country) {
  cli::cli_alert_info("fetching splits for ticker {ticker}|{exchange}|{country}")

  f_out <- fs::path(
    dir_dataout,
    country,
    glue::glue("{ticker}_eod-splits.csv")
  )

  fs::dir_create(dirname(f_out), recurse = TRUE)

  if (fs::file_exists(f_out)) {
    cli::cli_alert_success("\tfile {f_out} already exists..")
    return(invisible(TRUE))
  }

  url <- glue::glue('https://eodhd.com/api/splits/{ticker}.{exchange}?api_token={token}&fmt=json')

  #mem_cache <- memoise::cache_filesystem(cache_folder)
  #mem_get <- memoise::memoise(httr::GET, cache = mem_cache)
  # response <- mem_get(url)

  response <- httr::GET(url)

  if (httr::http_type(response) == "application/json") {

    cli::cli_alert_success("\tvalid content")

    content <- httr::content(response, "text", encoding = "UTF-8")

    if (content == "[]") {
      df <- dplyr::tibble()
    } else {
      df <- jsonlite::fromJSON(content) |>
        dplyr::mutate(
          ticker = ticker,
          exchange = exchange
        ) |>
        dplyr::mutate(date = as.Date(date))
    }

    readr::write_csv(df, f_out)

    cli::cli_alert_success("\tgot {nrow(df)} rows")

  } else {

    cli::cli_alert_danger("returned content for {ticker}|{country} is not json..")

    cli::cli_warn("returned content for {ticker}|{country} is not json..")

  }

  return(invisible(TRUE))
}
