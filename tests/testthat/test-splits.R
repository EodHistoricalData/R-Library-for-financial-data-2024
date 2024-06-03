test_that("fetching splits", {

  #' Fetches dividend data from eodhd
  skip_if(get_token() == get_demo_token(),
          "Found a test/demo token, which does not allow for querying splits data")
})
