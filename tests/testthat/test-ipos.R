test_that("ipos", {

  # test relies on calling api (we skip it on cran to save network bandwith)
  skip_if_offline()
  skip_on_cran() # too heavy for cran

  skip_if(get_token() == get_demo_token(),
          "Found a test/demo token, which does not allow for querying ipos")

  # suppressMessages({
  #   set_token()
  #
  #   df_ipos1 <- get_ipos()
  #
  #   expect_true(nrow(df_ipos1) > 0)
  #
  #   # run it again for testing local cache
  #   df_ipos2 <- get_ipos()
  #
  #   expect_true(identical(df_ipos1, df_news2))
  #
  #
  # })
})
