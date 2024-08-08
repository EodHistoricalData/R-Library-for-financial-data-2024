test_that("prices", {

  # test relies on calling api (we skip it on cran to save network bandwith)
  skip_if_offline()
  skip_on_cran() # too heavy for cran

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
