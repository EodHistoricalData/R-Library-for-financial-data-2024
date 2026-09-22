test_that("search and exchange details", {

  skip_if_offline()
  skip_on_cran()
  skip_without_paid_token()

  suppressMessages({

    df_search <- get_search("apple", limit = 5,
                            cache_folder = test_cache(), check_quota = FALSE)
    expect_true(nrow(df_search) > 0)
    expect_true("Code" %in% names(df_search))

    l_details <- get_exchange_details("US",
                                      cache_folder = test_cache(),
                                      check_quota = FALSE)
    expect_type(l_details, "list")
    expect_true("Name" %in% names(l_details))

  })
})

test_that("symbol changes, id mapping and screener", {

  skip_if_offline()
  skip_on_cran()
  skip_without_paid_token()

  suppressMessages({

    df_changes <- get_symbol_change_history(first_date = "2026-01-01",
                                            cache_folder = test_cache(),
                                            check_quota = FALSE)
    expect_true(nrow(df_changes) > 0)

    df_id <- get_id_mapping(symbol = "AAPL", exchange = "US",
                            cache_folder = test_cache(), check_quota = FALSE)
    expect_equal(nrow(df_id), 1)

    df_screener <- get_screener(
      filters = list(list("market_capitalization", ">", 1e12)),
      limit = 5,
      cache_folder = test_cache(),
      check_quota = FALSE
    )
    expect_true(nrow(df_screener) > 0)

  })
})
