#' Retrieves the list of available exchanges
#'
#' @return a dataframe with information about available exchanges
#' @export
#'
#' @inheritParams get_fundamentals
#'
#' @examples
#'
#' # you need a valid token (not test) for this to work
#' \dontrun{
#' set_token("YOUR_VALID_TOKEN")
#' df_exc <- get_exchanges()
#' }
#'
get_exchanges <- function(cache_folder = get_default_cache()) {

  cli::cli_h1("retrieving exchange list")

  token <- get_token()

  if (token == get_demo_token()) {
    cli::cli_abort(
      "You need a proper token (not \"{get_demo_token()}\") for retrieving the list of exchanges."
      )
  }

  f_out <-get_cache_file("cache", "exchange", cache_folder, "exchange-list")

  if (fs::file_exists(f_out)) {

    df_exc <- read_cache(f_out)

  } else {

    url <- glue::glue(
      '{get_base_url()}/exchanges-list/?api_token={token}&fmt=json'
    )

    content <- query_api(url)

    df_exc <- jsonlite::fromJSON(content)

    write_cache(df_exc, f_out)

  }

  cli::cli_alert_success("got {nrow(df_exc)} rows")

  return(df_exc)
}
