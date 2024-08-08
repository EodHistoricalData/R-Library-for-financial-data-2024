
<!-- README.md is generated from README.Rmd. Please edit that file -->

# About eodhdR2

![](inst/extdata/figs/website-eodhd.png)

<!-- badges: start -->

[![R-CMD-check](https://github.com/EodHistoricalData/R-Library-for-financial-data-2024/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/EodHistoricalData/R-Library-for-financial-data-2024/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

[eodhd](https://eodhd.com/) is a private company that offers APIs to a
set of comprehensive and high quality financial data for over 70+
exchanges across the world. This includes:

- Adjusted and unadjusted prices of financial contracts (equity, funds,
  ETF, cryptocurrencies, ..)
- Financial information of companies (Balance Sheet, Income/Cashflow
  statement)
- Valuation indicators
- And [more](https://eodhd.com/)..

Package eodhdR2 is the second and backwards incompatible version of
[eodhd](https://github.com/EodHistoricalData/EODHD-APIs-R-Financial-Library),
allowing fast and intelligent access to most of the API’s endpoints.

# Features

- A local caching system that saves all API queries to the disk,
  improving execution time and reducing api calls on repeated queries.
- A quota management system, informing the user of how much of the API
  daily quota was used and how much time is left to refresh it.
- Function for aggregating and organizing financial information into a
  single dataframe, allowing easier access to clean financial data in
  the [wide or long
  format](https://libguides.princeton.edu/R-reshape#:~:text=A%20dataset%20can%20be%20written,repeat%20in%20the%20first%20column.&text=We%20can%20see%20that%20in,value%20in%20the%20first%20column).

# Installation

``` r
# not yet in CRAN
#install.package("eodhdR2")

# development version
devtools::install_github("EodHistoricalData/R-Library-for-financial-data-2024")
```

# Usage

## Authentication

After registering in the [eodhd website](https://eodhd.com/) and
choosing a subscription, all users will authenticate an R session using
a token from the website. For that:

1)  Create an account at <https://eodhd.com/>
2)  Go in “Settings” and look for your API token

![](inst/extdata/figs/token.png)

While using `eodhdR2`, all authentications are managed with function
`eodhdR2::set_token()`:

``` r
eodhdR2::set_token("YOUR_TOKEN")
```

Alternatively, while testing the API, you can use the “demo” token for
demonstration.

``` r
token <- eodhdR2::get_demo_token()
eodhdR2::set_token(token)
#> ✔ eodhd API token set
#> ℹ Account name: API Documentation 2 (supportlevel1@eodhistoricaldata.com)
#> ℹ Quota: 94929 | 10000000
#> ℹ Subscription: demo
#> ✖ You are using a **DEMONSTRATION** token for testing pourposes, with
#> limited access to the data repositories. See <https://eodhd.com/>
#> for registration and, after finding your token, use it with
#> function eodhdR2::set_token("TOKEN").
```

# Examples

## Retrieving Financial Prices

``` r
ticker <- "AAPL"
exchange <- "US"

df_prices <- eodhdR2::get_prices(ticker, exchange)
#> 
#> ── retrieving price data for ticker AAPL|US ────────────────────────────────────
#> ! Quota status: 94930|10000000, refreshing in 6.57 hours
#> ℹ cache file '/tmp/Rtmperw7sw/eodhdR2-cache/AAPL_US_eodhd_prices.rds' saved
#> ✔ got 11004 rows of prices
#> ℹ got daily data from 1980-12-12 to 2024-08-07

head(df_prices)
#>         date    open    high     low   close adjusted_close    volume ticker
#> 1 1980-12-12 28.7392 28.8736 28.7392 28.7392         0.0990 469033600   AAPL
#> 2 1980-12-15 27.3728 27.3728 27.2608 27.2608         0.0939 175884800   AAPL
#> 3 1980-12-16 25.3792 25.3792 25.2448 25.2448         0.0870 105728000   AAPL
#> 4 1980-12-17 25.8720 26.0064 25.8720 25.8720         0.0892  86441600   AAPL
#> 5 1980-12-18 26.6336 26.7456 26.6336 26.6336         0.0918  73449600   AAPL
#> 6 1980-12-19 28.2464 28.3808 28.2464 28.2464         0.0973  48630400   AAPL
#>   exchange ret_adj_close
#> 1       US            NA
#> 2       US   -0.05151515
#> 3       US   -0.07348243
#> 4       US    0.02528736
#> 5       US    0.02914798
#> 6       US    0.05991285
```

``` r
library(ggplot2)

p <- ggplot(df_prices, aes(y = adjusted_close, x = date)) + 
  geom_line() + 
  theme_light() + 
  labs(title = "Adjusted Prices of AAPL",
       subtitle = "Prices are adjusted to splits, dividends and other corporate events",
       x = "Data",
       y = "Adjusted Prices")

p
```

<img src="man/figures/README-unnamed-chunk-6-1.png" width="100%" />

## Retrieving Dividends

``` r
ticker <- "AAPL"
exchange <- "US"

df_div <- eodhdR2::get_dividends(ticker, exchange)
#> 
#> ── retrieving dividends for ticker AAPL|US ─────────────────────────────────────
#> ! Quota status: 94945|10000000, refreshing in 6.56 hours
#> ℹ cache file '/tmp/Rtmperw7sw/eodhdR2-cache/AAPL_US_eodhd_dividends.rds' saved
#> ✔ got 84 rows of dividend data

head(df_div)
#>         date ticker exchange declarationDate recordDate paymentDate period
#> 1 1987-05-11   AAPL       US            <NA>       <NA>        <NA>   <NA>
#> 2 1987-08-10   AAPL       US            <NA>       <NA>        <NA>   <NA>
#> 3 1987-11-17   AAPL       US            <NA>       <NA>        <NA>   <NA>
#> 4 1988-02-12   AAPL       US            <NA>       <NA>        <NA>   <NA>
#> 5 1988-05-16   AAPL       US            <NA>       <NA>        <NA>   <NA>
#> 6 1988-08-15   AAPL       US            <NA>       <NA>        <NA>   <NA>
#>     value unadjustedValue currency
#> 1 0.00054         0.12096      USD
#> 2 0.00054         0.06048      USD
#> 3 0.00071         0.07952      USD
#> 4 0.00071         0.07952      USD
#> 5 0.00071         0.07952      USD
#> 6 0.00071         0.07952      USD
```

``` r
library(ggplot2)

p <- ggplot(df_div, aes(y = value, x = date)) + 
  geom_point(size = 1) + 
  theme_light() + 
  labs(title = "Adjusted Dividends of AAPL",
       x = "Data",
       y = "Adjusted Dividends")

p
```

<img src="man/figures/README-unnamed-chunk-8-1.png" width="100%" />

## Retrieving Fundamentals

``` r
ticker <- "AAPL"
exchange <- "US"

l_fun <- eodhdR2::get_fundamentals(ticker, exchange)
#> 
#> ── retrieving fundamentals for ticker AAPL|US ──────────────────────────────────
#> ! Quota status: 94958|10000000, refreshing in 6.56 hours
#> ✔ querying API
#> ✔ got 13 elements in raw list

names(l_fun)
#>  [1] "General"             "Highlights"          "Valuation"          
#>  [4] "SharesStats"         "Technicals"          "SplitsDividends"    
#>  [7] "AnalystRatings"      "Holders"             "InsiderTransactions"
#> [10] "ESGScores"           "outstandingShares"   "Earnings"           
#> [13] "Financials"
```

## Parsing financials (wide table)

``` r
wide_financials <- eodhdR2::parse_financials(l_fun, "wide")
#> 
#> ── Parsing financial data for Apple Inc | AAPL ──
#> 
#> ℹ parsing Balance_Sheet  data
#> ℹ    quarterly
#> ℹ    yearly
#> ℹ parsing Cash_Flow  data
#> ℹ    quarterly
#> ℹ    yearly
#> ℹ parsing Income_Statement  data
#> ℹ    quarterly
#> ℹ    yearly
#> ✔ got 561 rows of financial data (wide format)

head(wide_financials)
#> # A tibble: 6 × 127
#>   date       filing_date ticker company_name frequency type_financial
#>   <date>     <date>      <chr>  <chr>        <chr>     <chr>         
#> 1 2024-03-31 2024-05-03  AAPL   Apple Inc    quarterly Balance_Sheet 
#> 2 2023-12-31 2024-02-02  AAPL   Apple Inc    quarterly Balance_Sheet 
#> 3 2023-09-30 2023-11-03  AAPL   Apple Inc    quarterly Balance_Sheet 
#> 4 2023-06-30 2023-08-04  AAPL   Apple Inc    quarterly Balance_Sheet 
#> 5 2023-03-31 2023-05-05  AAPL   Apple Inc    quarterly Balance_Sheet 
#> 6 2022-12-31 2023-02-03  AAPL   Apple Inc    quarterly Balance_Sheet 
#> # ℹ 121 more variables: currency_symbol <chr>, totalAssets <dbl>,
#> #   intangibleAssets <dbl>, earningAssets <dbl>, otherCurrentAssets <dbl>,
#> #   totalLiab <dbl>, totalStockholderEquity <dbl>, deferredLongTermLiab <dbl>,
#> #   otherCurrentLiab <dbl>, commonStock <dbl>, capitalStock <dbl>,
#> #   retainedEarnings <dbl>, otherLiab <dbl>, goodWill <dbl>, otherAssets <dbl>,
#> #   cash <dbl>, cashAndEquivalents <dbl>, totalCurrentLiabilities <dbl>,
#> #   currentDeferredRevenue <dbl>, netDebt <dbl>, shortTermDebt <dbl>, …
```

## Parsing financials (long table)

``` r
long_financials <- eodhdR2::parse_financials(l_fun, "long")
#> 
#> ── Parsing financial data for Apple Inc | AAPL ──
#> 
#> ℹ parsing Balance_Sheet  data
#> ℹ    quarterly
#> ℹ    yearly
#> ℹ parsing Cash_Flow  data
#> ℹ    quarterly
#> ℹ    yearly
#> ℹ parsing Income_Statement  data
#> ℹ    quarterly
#> ℹ    yearly
#> ✔ got 67320 rows of financial data (long format)

head(long_financials)
#> # A tibble: 6 × 9
#>   date       filing_date ticker company_name frequency type_financial
#>   <date>     <date>      <chr>  <chr>        <chr>     <chr>         
#> 1 2024-03-31 2024-05-03  AAPL   Apple Inc    quarterly Balance_Sheet 
#> 2 2024-03-31 2024-05-03  AAPL   Apple Inc    quarterly Balance_Sheet 
#> 3 2024-03-31 2024-05-03  AAPL   Apple Inc    quarterly Balance_Sheet 
#> 4 2024-03-31 2024-05-03  AAPL   Apple Inc    quarterly Balance_Sheet 
#> 5 2024-03-31 2024-05-03  AAPL   Apple Inc    quarterly Balance_Sheet 
#> 6 2024-03-31 2024-05-03  AAPL   Apple Inc    quarterly Balance_Sheet 
#> # ℹ 3 more variables: currency_symbol <chr>, name <chr>, value <dbl>
```
