test_that("list of tickers", {

  skip_if_offline()
  skip_on_cran() # too heavy for cran

  skip_if(get_token() == get_demo_token(),
          "Found a test/demo token, which does not allow for listing tickers")

})
