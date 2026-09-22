test_that("splits", {

  skip_if_offline()
  skip_on_cran() # too heavy for cran
  skip_without_paid_token()

  suppressMessages({

    df_splits1 <- get_splits("AAPL", "US",
                             cache_folder = test_cache(), check_quota = FALSE)

    expect_true(nrow(df_splits1) > 0)
    expect_setequal(names(df_splits1), c("date", "split", "ticker", "exchange"))
    expect_s3_class(df_splits1$date, "Date")
    expect_equal(unique(df_splits1$ticker), "AAPL")
    expect_equal(unique(df_splits1$exchange), "US")

    # the 2020 four-for-one split has to be in there
    expect_true(as.Date("2020-08-31") %in% df_splits1$date)

    # run it again for testing local cache
    df_splits2 <- get_splits("AAPL", "US",
                             cache_folder = test_cache(), check_quota = FALSE)

    expect_true(identical(df_splits1, df_splits2))

  })
})
