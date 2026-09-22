test_that("real estate coverage and series", {

  skip_if_offline()
  skip_on_cran()
  skip_without_paid_token()

  suppressMessages({

    df_countries <- get_real_estate_countries(cache_folder = test_cache(),
                                              check_quota = FALSE)
    expect_true(nrow(df_countries) > 0)

    df_re <- get_real_estate(limit = 20, cache_folder = test_cache(),
                             check_quota = FALSE)
    expect_true(nrow(df_re) > 0)

    df_detail <- get_real_estate_detailed(limit = 20, cache_folder = test_cache(),
                                          check_quota = FALSE)
    expect_true(nrow(df_detail) > 0)

    df_series <- get_real_estate_series("US", cache_folder = test_cache(),
                                        check_quota = FALSE)
    expect_true(nrow(df_series) > 0)

  })
})
