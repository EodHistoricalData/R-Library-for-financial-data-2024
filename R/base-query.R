query_api <- function(url) {

  response <- httr::GET(url)
  parse_status_code(response$status_code)

  content <- httr::content(response, "text", encoding = "UTF-8")

  return(content)

}
