test_that("list of exchanges", {

  skip_if_offline()
  skip_on_cran() # too heavy for cran
  skip_without_paid_token()

  suppressMessages({

    df_exchanges1 <- get_exchanges(cache_folder = test_cache())

    expect_true(nrow(df_exchanges1) > 0)
    expect_true("Code" %in% names(df_exchanges1))
    expect_true("US" %in% df_exchanges1$Code)

    # run it again for testing local cache
    df_exchanges2 <- get_exchanges(cache_folder = test_cache())

    expect_true(identical(df_exchanges1, df_exchanges2))

  })
})

test_that("the exchange list refuses the demo token", {

  old_token <- Sys.getenv("eodhd-token")
  Sys.setenv("eodhd-token" = get_demo_token())
  on.exit(Sys.setenv("eodhd-token" = old_token), add = TRUE)

  expect_error(get_exchanges(), "proper token")

})
