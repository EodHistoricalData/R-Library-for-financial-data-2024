test_that("fundamentals", {


  temp_cache_folder <- fs::path_temp("oedhd-test-cache")

  suppressMessages({

    set_token()

    l_out1 <- get_fundamentals(
      ticker = "AAPL",
      exchange = "US",
      cache_folder = temp_cache_folder)

    df_financials <- parse_financials(l_out1)

    expect_true(is.list(l_out1))

    expect_true(nrow(df_financials) > 0)

    # run it again for cache results
    l_out2 <- get_fundamentals(
      ticker = "AAPL",
      exchange = "US",
      cache_folder = temp_cache_folder)

    df_financials <- parse_financials(l_out2)

    expect_true(identical(l_out1, l_out2))
  })



})
