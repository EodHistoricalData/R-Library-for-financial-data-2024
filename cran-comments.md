## R CMD check results

0 errors | 0 warnings | 0 notes

* checked locally with `R CMD check --as-cran` on macOS (R 4.6.1): Status OK
* tested on [github action](https://github.com/EodHistoricalData/R-Library-for-financial-data-2024/actions),
  passing for windows (latest), macos (latest), ubuntu (latest) and ubuntu (devel)

Tests that query the API are skipped on CRAN and without a token, so the check
makes no network calls to the data provider. All examples that need a paid
subscription are wrapped in `\dontrun{}`.

### updates

* coverage pass over the API: the package went from 13 to 60 exported functions,
  adding quotes and tick data, reference data, calendars, sentiment, macro and
  rates, credit risk, real estate, sanctions, options, bulk data, insider
  transactions and account info, plus `get_eodhd()` as a generic interface to
  any endpoint without a dedicated wrapper
* every package the code calls (cli, dplyr, fs, glue, httr, jsonlite, lubridate,
  purrr, readr, tidyr) was listed under `Suggests` and is now declared in
  `Imports`, so a plain `install.packages("eodhdR2")` no longer produces an
  installation in which the first function call fails
* fixed `get_intraday()`, which did not honour `first_date`, did not clip the
  result to the requested range, stopped the backwards walk at the first empty
  window and duplicated bars at window boundaries
* fixed `get_dividends()` and `get_index_composition()`, which ignored a
  configured base URL, and `get_index_composition()`, which did not report
  HTTP errors
* the test suite grew from 10 to 211 assertions
