test_that("earnings, trends, splits and dividend calendars", {

  skip_if_offline()
  skip_on_cran()
  skip_without_paid_token()

  suppressMessages({

    df_earnings <- get_earnings(symbols = "AAPL.US",
                                first_date = "2026-01-01",
                                last_date = "2026-12-31",
                                cache_folder = test_cache(),
                                check_quota = FALSE)
    expect_true(nrow(df_earnings) > 0)
    expect_s3_class(df_earnings$report_date, "Date")

    df_trends <- get_earnings_trends("AAPL.US",
                                     cache_folder = test_cache(),
                                     check_quota = FALSE)
    expect_true(nrow(df_trends) > 0)

    df_splits <- get_splits_calendar(first_date = "2026-08-01",
                                     last_date = "2026-10-01",
                                     cache_folder = test_cache(),
                                     check_quota = FALSE)
    expect_true(nrow(df_splits) > 0)

    df_div <- get_dividends_calendar(symbol = "AAPL.US",
                                     cache_folder = test_cache(),
                                     check_quota = FALSE)
    expect_true(nrow(df_div) > 0)

  })
})

test_that("the dividend calendar needs a symbol or a date", {

  expect_error(get_dividends_calendar(), "symbol or a single date")

})
