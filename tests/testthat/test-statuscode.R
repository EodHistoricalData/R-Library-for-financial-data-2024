test_that("status codes", {

  flag <- parse_status_code(200)

  expect_true(flag)
  expect_error(parse_status_code(400))
  expect_error(parse_status_code(403))

})
