#' Retrieves insider transactions
#'
#' Queries <https://eodhd.com/financial-apis/insider-transactions-api>, with the
#' purchases and sales reported by the insiders of US companies (SEC form 4).
#'
#' @inheritParams get_fundamentals
#' @param ticker an optional company ticker (e.g. "AAPL"). Default (NULL) returns
#'  the transactions of every company in the window.
#' @param exchange the exchange of the ticker (default "US")
#' @param first_date the first date of the window. Default is 90 days ago.
#' @param last_date the last date of the window. Default is today.
#' @param limit maximum number of rows (default 100, maximum 1000)
#'
#' @return A dataframe with the insider transactions
#' @export
#'
#' @examples
#' \dontrun{
#' set_token("YOUR_VALID_TOKEN")
#' df_insider <- get_insider_transactions("AAPL")
#' }
get_insider_transactions <- function(ticker = NULL,
                                     exchange = "US",
                                     first_date = Sys.Date() - 90,
                                     last_date = Sys.Date(),
                                     limit = 100,
                                     cache_folder = get_default_cache(),
                                     check_quota = TRUE) {

  cli::cli_h1("retrieving insider transactions")

  params <- list(
    code = if (is.null(ticker)) NULL else glue::glue("{ticker}.{exchange}"),
    from = as.character(as.Date(first_date)),
    to = as.character(as.Date(last_date)),
    limit = limit
  )

  df_out <- cached_api_df(
    endpoint = "insider-transactions",
    params = params,
    cache_folder = cache_folder,
    cache_prefix = "insider-transactions",
    check_quota = check_quota,
    post_fun = function(df) fix_date_cols(df, c("date", "transactionDate", "reportDate"))
  )

  cli::cli_alert_success("got {nrow(df_out)} transaction{?s}")

  return(df_out)

}
