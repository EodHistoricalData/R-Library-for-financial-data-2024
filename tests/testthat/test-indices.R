test_that("indices", {

  # test relies on calling api (we skip it on cran to save network bandwidth)
  skip_if_offline()
  skip_on_cran() # too heavy for cran

  skip_without_paid_token()

  suppressMessages({

    l_out1 <- get_index_composition("GSPC.INDX")

    expect_true(length(l_out1) > 0)

    # run it again for testing local cache
    l_out2 <- get_index_composition("GSPC.INDX")

    expect_true(identical(l_out1, l_out2))


  })
})

test_that("index list", {

  skip_if_offline()
  skip_on_cran()
  skip_without_paid_token()

  suppressMessages({

    df_list <- get_index_list(cache_folder = test_cache(), check_quota = FALSE)

    expect_true(nrow(df_list) > 0)
    expect_true("Code" %in% names(df_list))

  })
})
