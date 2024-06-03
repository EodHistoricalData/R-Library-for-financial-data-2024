

exchanges_list <- function() {

  token <- get_token()

  if (token == get_demo_token()) {
    cli::cli_abort("You need a proper token (not demonstration) for exchange list..")
  }

  url <- glue::glue(
    'https://eodhd.com/api/exchanges-list/?api_token={token}&fmt=json'
  )

  response <- httr::GET(url)

  if (httr::http_type(response) == "application/json") {
    content <- httr::content(response, "text", encoding = "UTF-8")

  } else {
    cli::cli_abort("Error while receiving data\n")
  }

  df <- jsonlite::fromJSON(content)

  return(df)
}
