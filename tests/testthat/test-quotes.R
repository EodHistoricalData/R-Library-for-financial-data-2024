test_that("live and delayed quotes", {

  skip_if_offline()
  skip_on_cran()
  skip_without_paid_token()

  suppressMessages({

    # one ticker answers a single object, several answer an array
    df_one <- get_real_time("AAPL", "US", check_quota = FALSE)
    expect_equal(nrow(df_one), 1)
    expect_equal(df_one$code, "AAPL.US")

    df_many <- get_real_time("AAPL", "US",
                             extra_tickers = c("MSFT.US", "VTI.US"),
                             check_quota = FALSE)
    expect_equal(nrow(df_many), 3)

    df_delayed <- get_us_quote_delayed(c("AAPL", "MSFT"), check_quota = FALSE)
    expect_equal(nrow(df_delayed), 2)
    expect_true("symbol" %in% names(df_delayed))

  })
})

test_that("ticks", {

  skip_if_offline()
  skip_on_cran()
  skip_without_paid_token()

  suppressMessages({

    first_time <- as.POSIXct("2026-09-15 14:00:00", tz = "UTC")
    last_time <- as.POSIXct("2026-09-15 14:05:00", tz = "UTC")

    df_ticks <- get_ticks("AAPL", "US",
                          first_time = first_time,
                          last_time = last_time,
                          limit = 50,
                          cache_folder = test_cache(),
                          check_quota = FALSE)

    expect_true(nrow(df_ticks) > 0)
    expect_s3_class(df_ticks$datetime, "POSIXct")
    expect_true(all(df_ticks$datetime >= first_time))

    # second call comes from the cache
    df_cached <- get_ticks("AAPL", "US",
                           first_time = first_time,
                           last_time = last_time,
                           limit = 50,
                           cache_folder = test_cache(),
                           check_quota = FALSE)

    expect_true(identical(df_ticks, df_cached))

  })
})

test_that("bulk eod, market cap and technicals", {

  skip_if_offline()
  skip_on_cran()
  skip_without_paid_token()

  suppressMessages({

    df_bulk <- get_bulk_eod("US", symbols = c("AAPL", "MSFT"),
                            cache_folder = test_cache(), check_quota = FALSE)
    expect_equal(nrow(df_bulk), 2)

    df_cap <- get_historical_market_cap("AAPL", "US",
                                        first_date = "2026-06-01",
                                        last_date = "2026-09-01",
                                        cache_folder = test_cache(),
                                        check_quota = FALSE)
    expect_true(nrow(df_cap) > 0)
    expect_s3_class(df_cap$date, "Date")

    df_sma <- get_technical("AAPL", "US", indicator = "sma", period = 50,
                            cache_folder = test_cache(), check_quota = FALSE)
    expect_true(nrow(df_sma) > 0)
    expect_true("sma" %in% names(df_sma))

  })
})
