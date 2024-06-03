
<!-- README.md is generated from README.Rmd. Please edit that file -->

# About eodhd

<!-- badges: start -->
<!-- badges: end -->

[EODHD](https://eodhd.com/) is a private company that offers access to a
set of comprehensive and high quality repositories of financial data for
over 70+ exchanges accross the world.

# Features

- cache
- quota management

## Installation

``` r
# not yet in CRAN
#install.package("eodhd2")

# development version
devtools::install_github("msperlin/eodhd2")
```

## Authentication

``` r
eodhd2::set_token()
#> ✔ eodhd API token set
#> ℹ Account name: API Documentation 2 (supportlevel1@eodhistoricaldata.com)
#> ℹ Quota: 41633 | 10000000
#> ℹ Subscription: demo
#> ✖ You are using a DEMONSTRATION token for testing pourposes, with limited access to the data repositories.
#> See <https://eodhd.com/> for registration and use function set_token(TOKEN) to set your own token.
```

## Usage

``` r
ticker <- "AAPL"
exchange <- "US"

df_fin <- eodhd2::get_fundamentals(ticker, exchange)
#> 
#> ── fetching fundamentals for ticker AAPL|US ────────────────────────────────────
#> ✔ eodhd API token set
#> ℹ Account name: API Documentation 2 (supportlevel1@eodhistoricaldata.com)
#> ℹ Quota: 41633 | 10000000
#> ℹ Subscription: demo
#> ✖ You are using a DEMONSTRATION token for testing pourposes, with limited access to the data repositories.
#> See <https://eodhd.com/> for registration and use function set_token(TOKEN) to set your own token.
#> ! Quota status: 41634|10000000, refreshing in 11.5 hours
#> ✔    querying API
#> ✔    got 13 elements in list
```

``` r

names(df_fin)
#>  [1] "General"             "Highlights"          "Valuation"          
#>  [4] "SharesStats"         "Technicals"          "SplitsDividends"    
#>  [7] "AnalystRatings"      "Holders"             "InsiderTransactions"
#> [10] "ESGScores"           "outstandingShares"   "Earnings"           
#> [13] "Financials"
```
