test_that("list of exchanges", {

  # test relies on calling api (we skip it on cran to save network)
  skip_if_offline()
  skip_on_cran() # too heavy for cran

  skip_if(get_token() == get_demo_token(),
          "Found a test/demo token, which does not allow for listing exchanges")

})
