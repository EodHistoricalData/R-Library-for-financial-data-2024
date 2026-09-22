## Version 0.8 (2026-09-22)

Bug fixes over the coverage pass of 0.7.

### Fixes

- `get_news()` compared a `POSIXct` timestamp with a `Date`, which R resolves by
  comparing the raw numbers (seconds against days). The comparison was always
  false, so a query never stopped at `first_date` and only ended when the api ran
  out of news. The dates are compared as dates now, and the timezone is pinned
- an empty body crashed `get_news()`, `get_dividends()`, `get_splits()` and
  `get_ipos()`: httr returns `NA_character_` (or a zero length vector) for an
  empty body, and `if (content == "[]")` cannot test `NA`. The same check now
  covers every empty shape, and the wrappers that read the response by hand
  (`get_prices()`, `get_tickers()`, `get_exchanges()`, `get_fundamentals()`,
  `get_index_composition()`, `get_sentiments()`, `get_news_word_weights()`)
  return an empty result instead of erroring
- `get_prices()` errored with "no applicable method for 'mutate'" when the api
  answered `[]`, instead of returning an empty dataframe
- `get_ipos()` aborted on an empty answer; it returns an empty dataframe now,
  like the other calendar wrappers
- `get_news()` could drop every row of a page when a news item had no `symbols`
  or `tags`; the symbol, tag and sentiment columns are built from a single parse,
  and the list index was off by one
- `get_index_composition()` errored on indices without a
  `HistoricalTickerComponents` block
- `set_token()` stored the token before validating it, so a rejected token stayed
  in `eodhd-token` and was returned by every later `get_token()`
- the price test compared `df_prices2` with itself, so it could never fail

### Internals

- new `is_empty_body()` helper in `R/utils.R`, reused by the response parser and
  by the wrappers that read the response by hand

## Version 0.7 (2026-09-22)

Coverage pass over the eodhd api. The package went from 13 to 60 exported
functions, and the wrappers now cover every core endpoint family plus the
Unicorn Bay marketplace products.

### New functions

- quotes and prices: `get_real_time()`, `get_us_quote_delayed()`, `get_ticks()`,
  `get_bulk_eod()`, `get_historical_market_cap()`, `get_technical()`
- reference data: `get_search()`, `get_exchange_details()`,
  `get_symbol_change_history()`, `get_id_mapping()`, `get_screener()`,
  `get_index_list()`
- calendars: `get_earnings()`, `get_earnings_trends()`, `get_splits_calendar()`,
  `get_dividends_calendar()`
- sentiment: `get_sentiments()`, `get_news_word_weights()`
- macro and rates: `get_macro_indicator()`, `get_economic_events()`,
  `get_commodities()`, `get_ust_rates()`, `get_policy_rates()`,
  `get_reference_rates()`, `get_funding_stress_spreads()`
- credit risk: `get_sovereign_risk_premium()`, `get_sovereign_credit_ratings()`,
  `get_sovereign_cds_spreads()`, `get_default_spreads()`, `get_corporate_cmdi()`,
  `get_corporate_hqm_yields()`, `get_cds_market_aggregates()`
- real estate: `get_real_estate_countries()`, `get_real_estate()`,
  `get_real_estate_detailed()`, `get_real_estate_series()`
- sanctions: `get_sanctions_entities()`, `get_sanctions_vessels()`,
  `get_sanctions_programs()`, `get_sanctions_sources()`
- options (Unicorn Bay): `get_options_underlyings()`, `get_options_contracts()`,
  `get_options_eod()`
- bulk and insider: `get_bulk_fundamentals()`, `get_insider_transactions()`
- account: `get_user_info()`
- `get_eodhd()`, an escape hatch that queries any endpoint the package does not
  wrap yet, with the same token, cache and quota handling

### Fixes

- every package the code actually calls (cli, dplyr, fs, glue, httr, jsonlite,
  lubridate, purrr, readr, tidyr) sat in `Suggests`, so a plain
  `install.packages("eodhdR2")` installed none of them and the first call
  failed with "there is no package called 'cli'". They are declared in
  `Imports` now
- `get_intraday()` did not honour `first_date`: the first window always started
  `offset_delta` days before `last_date`, and the result was never clipped to
  the requested range, so a one week query returned three months of bars. A
  window with no data also ended the walk, silently dropping everything older,
  and consecutive windows overlapped at the boundary, duplicating bars
- `get_dividends()` and `get_index_composition()` ignored the configured base url
- `get_index_composition()` bypassed the shared request handler, so http errors
  were not reported
- the base url carried a trailing slash while seven of eight call sites added
  one of their own, producing `https://eodhd.com/api//eod/...`
- typo in the `set_token()` message
- the README told readers to run `install.package("eodhdR2")`, which is not a
  function -- reported by a user through support

### Documentation

- the README now lists every exported function by family

### Internals

- new shared request layer (`R/api-core.R`) with one parser that handles the
  five response shapes the api uses: arrays, single objects, JSON:API
  envelopes, symbol-keyed objects and columnar payloads
- `get_eodhd()` accepts an endpoint written with a leading slash, the way the
  documentation prints it, and refuses a full url instead of building a
  nonsense request out of it
- cache file names are built from a length prefixed encoding of the parameter
  list, so no two parameter sets can be served each other's cached answer
- test suite grew from 10 to 211 assertions, covering every new family live plus
  offline tests for the parser, the cache keys and the hash

## Version 0.6 (2025-11-06)

- implemented `get_index_composition()`, a function to fetch index composition from eodhd
- fixed slow tests for `get_news()`

## Version 0.5.2 (2025-07-28)

- implemented `get_intraday()`, a function to download intraday prices from eodhd

## Version 0.5.1 (2024-09-03)

- implemented `get_news()`
- implemented `get_ipos()`

## Version 0.5.0 (2024-08-08)

- first version on CRAN
