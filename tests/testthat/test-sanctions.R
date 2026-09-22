test_that("sanctions lists", {

  skip_if_offline()
  skip_on_cran()
  skip_without_paid_token()

  suppressMessages({

    df_entities <- get_sanctions_entities(limit = 20, cache_folder = test_cache(),
                                          check_quota = FALSE)
    expect_true(nrow(df_entities) > 0)

    df_vessels <- get_sanctions_vessels(limit = 20, cache_folder = test_cache(),
                                        check_quota = FALSE)
    expect_true(nrow(df_vessels) > 0)

    df_programs <- get_sanctions_programs(cache_folder = test_cache(),
                                          check_quota = FALSE)
    expect_true(nrow(df_programs) > 0)

    df_sources <- get_sanctions_sources(cache_folder = test_cache(),
                                        check_quota = FALSE)
    expect_true(nrow(df_sources) > 0)

  })
})
