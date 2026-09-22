test_that("list of tickers", {

  skip_if_offline()
  skip_on_cran() # too heavy for cran
  skip_without_paid_token()

  suppressMessages({

    df_tickers1 <- get_tickers("US", cache_folder = test_cache())

    expect_true(nrow(df_tickers1) > 1000)
    expect_true(all(c("Code", "Name", "Exchange") %in% names(df_tickers1)))
    expect_true("AAPL" %in% df_tickers1$Code)

    # run it again for testing local cache
    df_tickers2 <- get_tickers("US", cache_folder = test_cache())

    expect_true(identical(df_tickers1, df_tickers2))

  })
})

test_that("the ticker list refuses the demo token", {

  old_token <- Sys.getenv("eodhd-token")
  Sys.setenv("eodhd-token" = get_demo_token())
  on.exit(Sys.setenv("eodhd-token" = old_token), add = TRUE)

  expect_error(get_tickers("US"), "proper token")

})
