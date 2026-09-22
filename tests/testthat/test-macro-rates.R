test_that("macro indicators and economic events", {

  skip_if_offline()
  skip_on_cran()
  skip_without_paid_token()

  suppressMessages({

    df_gdp <- get_macro_indicator("USA", "gdp_current_usd",
                                  cache_folder = test_cache(),
                                  check_quota = FALSE)
    expect_true(nrow(df_gdp) > 0)

    df_events <- get_economic_events(first_date = Sys.Date() - 7,
                                     last_date = Sys.Date(),
                                     country = "US",
                                     limit = 20,
                                     cache_folder = test_cache(),
                                     check_quota = FALSE)
    expect_true(nrow(df_events) > 0)

  })
})

test_that("commodities and rates", {

  skip_if_offline()
  skip_on_cran()
  skip_without_paid_token()

  suppressMessages({

    df_wti <- get_commodities("WTI", first_date = "2026-01-01",
                              cache_folder = test_cache(), check_quota = FALSE)
    expect_true(nrow(df_wti) > 0)

    for (type in c("yield", "bill", "long-term", "real-yield")) {
      df_ust <- get_ust_rates(type, year = 2026, limit = 20,
                              cache_folder = test_cache(), check_quota = FALSE)
      expect_true(nrow(df_ust) > 0)
      expect_s3_class(df_ust$date, "Date")
    }

    df_policy <- get_policy_rates(limit = 20, cache_folder = test_cache(),
                                  check_quota = FALSE)
    expect_true(nrow(df_policy) > 0)

    df_ref <- get_reference_rates(limit = 20, cache_folder = test_cache(),
                                  check_quota = FALSE)
    expect_true(nrow(df_ref) > 0)

    df_spreads <- get_funding_stress_spreads(cache_folder = test_cache(),
                                             check_quota = FALSE)
    expect_true(nrow(df_spreads) > 0)

  })
})

test_that("get_ust_rates only accepts the four known curves", {

  expect_error(get_ust_rates("not-a-curve"))

})
