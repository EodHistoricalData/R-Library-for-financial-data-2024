test_that("news", {

  # test relies on calling api (we skip it on cran to save network bandwith)
  skip_if_offline()
  skip_on_cran() # too heavy for cran

  suppressMessages({
    set_token()

    df_news1 <- get_news(
      ticker = "AAPL",
      exchange = "US"
    )

    expect_true(nrow(df_news1) > 0)

    # run it again for testing local cache
    df_news2 <- get_news(
      ticker = "AAPL",
      exchange = "US"
    )

    expect_true(identical(df_news1, df_news2))


  })
})
