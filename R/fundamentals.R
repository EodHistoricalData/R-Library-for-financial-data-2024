#' Retrieves and parses fundamental and financial data from eodhd api
#'
#' This function will download raw data from the fundamental end point of eodhd <https://eodhd.com/financial-apis/stock-etfs-fundamental-data-feeds> and
#' return a list. The raw data includes:
#' * General information for the company (code, ISIN, currency, ..)
#' * Financial highlights
#' * Valuation
#' * Raw financial data (see [eodhdR2::parse_financials()] for parsing this data)
#' * and many more (see example for more details regarding the output)
#'
#' @param ticker A company ticker (e.g. AAPL). You can find all tickers for a particular exchange with [eodhdR2::get_tickers()].
#' @param exchange A exchange symbol (e.g. US). You can find all tickers for a particular exchange with [eodhdR2::get_tickers()]. Be aware that, for US companies, the exchange symbols is simply "US"
#' @param cache_folder A local directory to store cache files. By default, all functions use a temporary path, meaning that the caching system
#' is session persistent (it will remove all files when you exit your R session). If you want a persistent caching system, simply point argument
#' cache_folder to a local directory in your filesystem. Be aware, however, that a persistent cache will not refresh your data for new api queries.
#' @param check_quota A flag (TRUE/FALSE) for whether to check the current quota status from the api. This option implies a small cost of execution
#' time. If you need speed, just set it to FALSE.
#'
#' @return  a list with several fundamental information
#' @export
#'
#' @examples
#' \dontrun{
#' set_token(get_demo_token())
#' l_out <- get_fundamentals(ticker = "AAPL", exchange = "US")
#' names(l_out)
#' }
get_fundamentals <- function(ticker = "AAPL",
                             exchange = "US",
                             cache_folder = get_default_cache(),
                             check_quota = TRUE) {

  cli::cli_h1("retrieving fundamentals for ticker {ticker}|{exchange}")

  token <- get_token()

  if (check_quota) {
    get_quota_status()
  }

  f_out <- fs::path(
    cache_folder,
    glue::glue("{ticker}_{exchange}_eod-fundamentals.rds")
  )

  fs::dir_create(dirname(f_out), recurse = TRUE)

  if (fs::file_exists(f_out)) {

    l_out <- readr::read_rds(f_out)

  } else {

    cli::cli_alert_success("querying API")

    url <- glue::glue('{get_base_url()}/fundamentals/{ticker}.{exchange}?api_token={token}&fmt=json')

    response <- httr::GET(url)

    parse_status_code(response$status_code)

    content <- httr::content(response,
                             "text",
                             encoding = "UTF-8")

    l_out <- jsonlite::fromJSON(content)
    readr::write_rds(l_out, f_out)
  }

  cli::cli_alert_success("got {length(l_out)} elements in raw list")

  return(l_out)

}
