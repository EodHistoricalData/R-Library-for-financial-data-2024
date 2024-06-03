
get_quota <- function(token = get_demo_token()) {

  url <- glue::glue('https://eodhd.com/api/user?api_token={token}')

  content <- query_api(url)

  json_data <- jsonlite::fromJSON(content)

  return(json_data)

}
