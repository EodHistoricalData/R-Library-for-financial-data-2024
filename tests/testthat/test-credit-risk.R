test_that("sovereign risk, ratings and cds", {

  skip_if_offline()
  skip_on_cran()
  skip_without_paid_token()

  suppressMessages({

    df_premium <- get_sovereign_risk_premium(limit = 20,
                                             cache_folder = test_cache(),
                                             check_quota = FALSE)
    expect_true(nrow(df_premium) > 0)

    df_ratings <- get_sovereign_credit_ratings(limit = 20,
                                               cache_folder = test_cache(),
                                               check_quota = FALSE)
    expect_true(nrow(df_ratings) > 0)

    df_cds <- get_sovereign_cds_spreads(limit = 20,
                                        cache_folder = test_cache(),
                                        check_quota = FALSE)
    expect_true(nrow(df_cds) > 0)

  })
})

test_that("corporate credit series", {

  skip_if_offline()
  skip_on_cran()
  skip_without_paid_token()

  suppressMessages({

    df_default <- get_default_spreads(limit = 20, cache_folder = test_cache(),
                                      check_quota = FALSE)
    expect_true(nrow(df_default) > 0)

    df_cmdi <- get_corporate_cmdi(limit = 20, cache_folder = test_cache(),
                                  check_quota = FALSE)
    expect_true(nrow(df_cmdi) > 0)

    df_hqm <- get_corporate_hqm_yields(limit = 20, cache_folder = test_cache(),
                                       check_quota = FALSE)
    expect_true(nrow(df_hqm) > 0)

    df_agg <- get_cds_market_aggregates(limit = 20, cache_folder = test_cache(),
                                        check_quota = FALSE)
    expect_true(nrow(df_agg) > 0)

  })
})
