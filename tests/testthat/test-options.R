test_that("options underlyings, contracts and eod", {

  skip_if_offline()
  skip_on_cran()
  skip_without_paid_token()

  suppressMessages({

    df_under <- get_options_underlyings(cache_folder = test_cache(),
                                        check_quota = FALSE)
    expect_true(nrow(df_under) > 0)
    expect_equal(names(df_under), "underlying_symbol")

    # the exchange suffix is trimmed before the call -- the endpoint is us only
    df_contracts <- get_options_contracts("AAPL.US", limit = 10,
                                          cache_folder = test_cache(),
                                          check_quota = FALSE)
    expect_equal(nrow(df_contracts), 10)
    expect_true("contract" %in% names(df_contracts))
    # the json:api envelope must not leak into the columns
    expect_false(any(duplicated(names(df_contracts))))

    df_eod <- get_options_eod("AAPL", limit = 10, cache_folder = test_cache(),
                              check_quota = FALSE)
    expect_equal(nrow(df_eod), 10)

  })
})
