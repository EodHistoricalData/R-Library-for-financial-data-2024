test_that("prices", {

  suppressMessages({
    set_token()

    df_prices1 <- get_prices(
      ticker = "AAPL",
      exchange = "US"
      )

    expect_true(nrow(df_prices1) > 0)

    # run it again for testing local cache
    df_prices2 <- get_prices(
      ticker = "AAPL",
      exchange = "US"
    )

    expect_true(identical(df_prices2, df_prices2))


  })
})
