#' Parses financial data from the API
#'
#' @param l_out List from get_fundamental()
#'
#' @export
#'
#' @examples
#' # no example
#'
parse_financials <- function(l_out, type_table = "wide") {

  possible_values <- c("long", "wide")
  if (!type_table %in% possible_values) {
    cli::cli_abort("argument type_table can only be {possible_values}")
  }

  ticker <- l_out$General$Code
  this_name <- l_out$General$Name
  currency <- l_out$General$CurrencyCode

  cli::cli_h2("Parsing financial data for {this_name} | {ticker}")

  Financials <- l_out$Financials
  names_fin <- names(Financials)

  df_financials <- dplyr::tibble()
  for (i_fin in names_fin) {

    cli::cli_alert_info("parsing {i_fin}  data")
    this_fin <- Financials[[i_fin]]

    currency <- this_fin$currency_symbol

    names_freq <- c("quarterly", "yearly")

    for (i_freq in names_freq) {
      cli::cli_alert_info("\t{i_freq}")

      df_this <- purrr::map_df(this_fin[[i_freq]], parse_single_financial) |>
        dplyr::mutate(ticker = ticker,
                      company_name = this_name,
                      frequency = i_freq,
                      type_financial = i_fin,
                      .after = filing_date)

      df_financials <- dplyr::bind_rows(
        df_financials,
        df_this
      )
    }


  }

  if (type_table == "long") {

    all_names <- names(df_financials)
    fixed_names <- c("date", "filing_date", "ticker", "company_name", "frequency", "type_financial",
                     "currency_symbol")
    to_pivot <- setdiff(all_names, fixed_names)

    df_financials <- df_financials |>
      tidyr::pivot_longer(
        cols = dplyr::all_of(to_pivot))

  }
  cli::cli_alert_success("got {nrow(df_financials)} rows of financial data ({type_table} format)")

  return(df_financials)

}


#' organizes financial data
#'
#' @noRd
parse_single_financial <- function(x) {

  elements <- purrr::map(x, fix_null)

  elements$date <- as.Date(elements$date)
  elements$filing_date <- as.Date(elements$filing_date)

  non_numeric_cols <- c("date", "filing_date", "currency_symbol")
  numeric_cols <- setdiff(names(elements), non_numeric_cols)

  for (i_name in numeric_cols) {
    elements[[i_name]] <- as.numeric(    elements[[i_name]] )
  }

  df_out <- dplyr::as_tibble(elements)

  return(df_out)
}
