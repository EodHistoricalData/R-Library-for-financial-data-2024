test_that("indices", {

  # test relies on calling api (we skip it on cran to save network bandwidth)
  skip_if_offline()
  skip_on_cran() # too heavy for cran

  suppressMessages({
    set_token()

    skip_if(
      get_token() == get_demo_token(),
      "Found a test/demo token, which does not allow for fetching index composition"
      )

    l_out1 <- get_index_composition("GSPC.INDX")

    expect_true(length(l_out1) > 0)

    # run it again for testing local cache
    l_out2 <- get_index_composition("GSPC.INDX")

    expect_true(identical(l_out1, l_out2))


  })
})
