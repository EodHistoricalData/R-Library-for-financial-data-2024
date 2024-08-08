test_that("dividends", {

  # test relies on calling api (we skip it on cran to save network)
  skip_if_offline()
  skip_on_cran() # too heavy for cran

  suppressMessages({
    set_token()

    df_div1 <- get_dividends("AAPL", "US")

    expect_true(nrow(df_div1) > 0)

    # run it again to get cached result
    df_div2 <- get_dividends("AAPL", "US")

  })

  expect_true(identical(df_div2, df_div1))
})
