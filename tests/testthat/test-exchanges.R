test_that("list of exchanges", {

  skip_if(get_token() == get_demo_token(),
          "Found a test/demo token, which does not allow for listing exchanges")

})
