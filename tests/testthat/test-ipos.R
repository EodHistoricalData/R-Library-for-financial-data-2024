test_that("ipos", {

  # test relies on calling api (we skip it on cran to save network bandwith)
  skip_if_offline()
  skip_on_cran() # too heavy for cran
  skip_without_paid_token()

  suppressMessages({

    df_ipos1 <- get_ipos(first_date = "2026-01-01",
                         last_date = "2026-06-30",
                         cache_folder = test_cache(),
                         check_quota = FALSE)

    expect_true(nrow(df_ipos1) > 0)
    expect_s3_class(df_ipos1$start_date, "Date")
    # a few rows carry no start date at all, so the window is checked on the rest
    expect_true(any(!is.na(df_ipos1$start_date)))
    expect_true(all(df_ipos1$start_date >= as.Date("2026-01-01"), na.rm = TRUE))
    expect_true(all(df_ipos1$start_date <= as.Date("2026-06-30"), na.rm = TRUE))

    # run it again for testing local cache
    df_ipos2 <- get_ipos(first_date = "2026-01-01",
                         last_date = "2026-06-30",
                         cache_folder = test_cache(),
                         check_quota = FALSE)

    expect_true(identical(df_ipos1, df_ipos2))

  })
})
