## R CMD check results

0 errors | 0 warnings | 0 notes

* This is an update, and a change of maintainer: the package moves from
  Marcelo S. Perlin, who wrote it under contract and stays on as author, to
  Alex Pletnev at EODHD, the company that owns the API the package serves.
  The previous maintainer has been asked to confirm the handover by email.
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
* fixed `get_splits()`, which reported the ratio of the wrong row and dropped
  the last split of the series
* fixed `get_intraday()`, which ignored `first_date` whenever the requested
  window needed more than one API call
* fixed `get_dividends()` and `get_index_composition()`, which ignored a
  configured base URL, and `get_index_composition()`, which did not report
  HTTP errors
* the test suite grew from 10 to 198 assertions
