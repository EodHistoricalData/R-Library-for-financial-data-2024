test_that("intraday", {

  # test relies on calling api (we skip it on cran to save network bandwidth)
  skip_if_offline()
  skip_on_cran() # too heavy for cran

  suppressMessages({
    set_token()

    df_intraday1 <- get_intraday(
      ticker = "AAPL",
      exchange = "US"
    )

    expect_true(nrow(df_intraday1) > 0)

    # run it again for testing local cache
    df_intraday2 <- get_intraday(
      ticker = "AAPL",
      exchange = "US"
    )

    expect_true(identical(df_intraday1, df_intraday2))


  })
})
