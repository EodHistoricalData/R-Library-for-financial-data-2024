test_that("news", {

  # test relies on calling api (we skip it on cran to save network bandwidth)
  skip_if_offline()
  skip_on_cran() # too heavy for cran

  suppressMessages({
    set_token()

    last_date <- Sys.Date()
    first_date <- Sys.Date() - 5

    df_news1 <- get_news(
      ticker = "AAPL",
      exchange = "US",
      first_date = first_date,
      last_date = last_date
    )

    expect_true(nrow(df_news1) > 0)

    # run it again for testing local cache
    df_news2 <- get_news(
      ticker = "AAPL",
      exchange = "US",
      first_date = first_date,
      last_date = last_date
    )

    expect_true(identical(df_news1, df_news2))


  })
})
