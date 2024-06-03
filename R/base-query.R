#' Low level (unexported) function for fetching data from API
#'
#' @param url A well formed url
#'
#' @return a content (txt) object
#'
#' @noRd
query_api <- function(url) {

  response <- httr::GET(url)
  parse_status_code(response$status_code)

  content <- httr::content(response, "text", encoding = "UTF-8")

  return(content)

}

get_base_url <- function() {
  base_url <- "https://eodhd.com/api/"
  return(base_url)

}
