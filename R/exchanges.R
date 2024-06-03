#' Fetches exchange list from api
#'
#' @return a dataframe with information about available exchanges
#' @export
#'
#' @examples
#'
#' # you need a valid token (not test) for this to work
#' \dontrun{
#' df_exc <- get_exchanges()
#' }
#'
#'
get_exchanges <- function() {

  token <- get_token()
  if (token == get_demo_token()) {
    cli::cli_abort("You need a proper token (not demonstration) for exchange list..")
  }

  url <- glue::glue(
    '{get_base_url()}/exchanges-list/?api_token={token}&fmt=json'
  )

  content <- query_api(url)

  df_exc <- jsonlite::fromJSON(content)

  return(df_exc)
}
