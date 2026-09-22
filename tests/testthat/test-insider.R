test_that("insider transactions", {

  skip_if_offline()
  skip_on_cran()
  skip_without_paid_token()

  suppressMessages({

    df_insider <- get_insider_transactions("MSFT", "US",
                                           first_date = "2026-01-01",
                                           limit = 20,
                                           cache_folder = test_cache(),
                                           check_quota = FALSE)
    expect_true(nrow(df_insider) > 0)
    expect_s3_class(df_insider$date, "Date")

  })
})
