
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
#> ℹ Quota: 40213 | 10000000
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
#> ! Quota status: 40213|10000000, refreshing in 11.9 hours
#> ✔    querying API
#> ✔    got 13 elements in list
```

The goal of eodhdR is to …

## Installation

You can install the development version of eodhdR like so:

``` r
# FILL THIS IN! HOW CAN PEOPLE INSTALL YOUR DEV PACKAGE?
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(eodhdR)
## basic example code
```

What is special about using `README.Rmd` instead of just `README.md`?
You can include R chunks like so:

``` r
summary(cars)
#>      speed           dist       
#>  Min.   : 4.0   Min.   :  2.00  
#>  1st Qu.:12.0   1st Qu.: 26.00  
#>  Median :15.0   Median : 36.00  
#>  Mean   :15.4   Mean   : 42.98  
#>  3rd Qu.:19.0   3rd Qu.: 56.00  
#>  Max.   :25.0   Max.   :120.00
```

You’ll still need to render `README.Rmd` regularly, to keep `README.md`
up-to-date. `devtools::build_readme()` is handy for this.

You can also embed plots, for example:

<img src="man/figures/README-pressure-1.png" width="100%" />

In that case, don’t forget to commit and push the resulting figure
files, so they display on GitHub and CRAN.
