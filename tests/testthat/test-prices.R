test_that("fetching prices", {

  set_token(get_demo_token())

  df_prices <- get_prices(
    ticker = "AAPL",
    exchange = "US")

  expect_true(nrow(df_prices) > 0)
})
