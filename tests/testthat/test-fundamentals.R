test_that("fundamentals", {

  set_token()

  temp_cache_folder <- fs::path_temp("oedhd-cache")

  l_out <- get_fundamentals(
    ticker = "AAPL",
    exchange = "US",
    cache_folder = temp_cache_folder)

  expect_true(is.list(l_out))

  df_financials <- parse_financials(l_out)

  expect_true(nrow(df_financials) > 0)

})
