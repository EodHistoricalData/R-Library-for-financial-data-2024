get_tickers <- function(exchange, token) {

  cli::cli_alert_info("fetching tickers for {exchange}")

  url <- glue::glue('https://eodhd.com/api/exchange-symbol-list/{exchange}?api_token={token}&fmt=json')

  response <- httr::GET(url)

  if (httr::http_type(response) == "application/json") {

    content <- httr::content(response, "text", encoding = "UTF-8")

  } else {
    cli::cli_abort("Error while receiving data\n")
  }
  df <- jsonlite::fromJSON(content)

  return(df)

}
