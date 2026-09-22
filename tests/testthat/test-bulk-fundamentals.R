test_that("bulk fundamentals come back keyed by ticker", {

  skip_if_offline()
  skip_on_cran()
  skip_without_paid_token()

  suppressMessages({

    l_bulk <- get_bulk_fundamentals("US", symbols = c("AAPL", "MSFT"),
                                    cache_folder = test_cache(),
                                    check_quota = FALSE)

    expect_type(l_bulk, "list")
    expect_setequal(names(l_bulk), c("AAPL", "MSFT"))
    # the paging keys of the envelope are dropped
    expect_false(any(c("offset", "limit", "count") %in% names(l_bulk)))
    expect_equal(l_bulk$AAPL$General$Code, "AAPL")

  })
})
