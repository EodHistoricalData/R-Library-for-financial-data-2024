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

test_that("intraday honours the requested window", {

  skip_if_offline()
  skip_on_cran()
  skip_without_paid_token()

  suppressMessages({

    first_date <- as.Date("2026-08-03")
    last_date <- as.Date("2026-08-07")

    df_intraday <- get_intraday(
      ticker = "AAPL",
      exchange = "US",
      frequency = "5m",
      first_date = first_date,
      last_date = last_date,
      cache_folder = test_cache(),
      check_quota = FALSE
    )

    expect_true(nrow(df_intraday) > 0)

    # the api serves a fixed span per call, so the function walks backwards --
    # nothing outside the asked window may survive the walk
    expect_true(all(as.Date(df_intraday$datetime) >= first_date))
    expect_true(all(as.Date(df_intraday$datetime) <= last_date))

    # and the window must actually be reached, not truncated to the last span
    expect_true(min(as.Date(df_intraday$datetime)) <= as.Date("2026-08-04"))

  })
})

test_that("intraday rejects an inverted window and an unknown frequency", {

  # both checks sit before the first request, but get_token() runs in between,
  # so the token has to be present for the test to reach them
  old_token <- Sys.getenv("eodhd-token")
  Sys.setenv("eodhd-token" = "demo")
  on.exit(Sys.setenv("eodhd-token" = old_token), add = TRUE)

  expect_error(
    get_intraday(first_date = Sys.Date(), last_date = Sys.Date() - 7,
                 check_quota = FALSE),
    "higher than last_date"
  )

  expect_error(
    get_intraday(frequency = "3m", check_quota = FALSE),
    "not available in possible values"
  )

})
