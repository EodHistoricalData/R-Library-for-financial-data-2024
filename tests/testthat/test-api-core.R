test_that("str_hash is stable and 32 bits wide", {

  expect_equal(nchar(str_hash("AAPL.US")), 8)
  expect_identical(str_hash("AAPL.US"), str_hash("AAPL.US"))
  expect_false(identical(str_hash("AAPL.US"), str_hash("MSFT.US")))

  # the reference values come from an independent fnv-1a implementation
  expect_identical(str_hash("AAPL.US"), "7988eaf7")
  expect_identical(str_hash(paste0(rep("a", 300), collapse = "")), "279e8f01")

  # the empty string is the offset basis
  expect_identical(str_hash(""), "811c9dc5")

  # the hash runs over the utf-8 bytes, so two code points that share a low
  # byte must not collide
  expect_false(identical(str_hash("A"), str_hash("\u0141")))
  expect_equal(nchar(str_hash("\u0141")), 8)

  # the value has to stay inside the 32 bit range for every length
  for (n in 1:40) {
    expect_equal(nchar(str_hash(strrep("z", n))), 8)
  }

})

test_that("build_cache_name is sorted, sanitised and bounded", {

  n1 <- build_cache_name("eod", list(to = "2026-01-02", from = "2026-01-01"))
  n2 <- build_cache_name("eod", list(from = "2026-01-01", to = "2026-01-02"))

  # the order of the arguments must not create a second cache file
  expect_identical(n1, n2)

  # no characters that are invalid in a file name
  n3 <- build_cache_name("opt", list(`filter[symbol]` = "AAPL.US"))
  expect_false(grepl("[^A-Za-z0-9._-]", n3))

  # long parameter sets are truncated, but stay unique
  long_a <- build_cache_name("x", list(a = paste0(rep("a", 300), collapse = "")))
  long_b <- build_cache_name("x", list(a = paste0(rep("b", 300), collapse = "")))
  expect_true(nchar(long_a) < 120)
  expect_false(identical(long_a, long_b))

  # NULL parameters are ignored
  expect_identical(
    build_cache_name("eod", list(from = "2026-01-01", to = NULL)),
    build_cache_name("eod", list(from = "2026-01-01"))
  )

  # sanitising strips the brackets, so two parameter sets that only differ in
  # them must still get their own file
  expect_false(identical(
    build_cache_name("opt", list(`filter[year]` = 2026)),
    build_cache_name("opt", list(filteryear = 2026))
  ))

  # an unnamed parameter cannot be keyed, and would silently share a file
  expect_error(build_cache_name("eod", list("2026-01-01")), "needs a name")

})

test_that("parse_api_df handles the shapes of the api", {

  # empty payloads
  expect_equal(nrow(parse_api_df("[]")), 0)
  expect_equal(nrow(parse_api_df("{}")), 0)

  # plain array of objects
  df_array <- parse_api_df('[{"a":1,"b":"x"},{"a":2,"b":"y"}]')
  expect_equal(nrow(df_array), 2)
  expect_equal(df_array$b, c("x", "y"))

  # a single object is one row, not one row per field
  df_one <- parse_api_df('{"code":"AAPL.US","close":100}')
  expect_equal(nrow(df_one), 1)
  expect_equal(df_one$code, "AAPL.US")

  # named payload element
  df_element <- parse_api_df('{"earnings":[{"code":"AAPL.US"}]}', element = "earnings")
  expect_equal(nrow(df_element), 1)

  # json:api document
  df_jsonapi <- parse_api_df('{"data":[{"type":"t","id":"1","attributes":{"date":"2026-01-01","rate":4.5}}]}')
  expect_equal(nrow(df_jsonapi), 1)
  expect_true(all(c("date", "rate") %in% names(df_jsonapi)))

})

test_that("the json:api envelope does not collide with the payload", {

  # both the envelope and the payload have a field called type
  content <- '{"data":[{"type":"options-contracts","id":"1","attributes":{"type":"call","strike":100}}]}'

  df_out <- parse_api_df(content)

  expect_equal(nrow(df_out), 1)
  expect_equal(df_out$type, "call")
  expect_equal(sum(names(df_out) == "type"), 1)

})

test_that("fix_date_cols only touches the columns that are there", {

  df_in <- dplyr::tibble(date = "2026-01-01", value = 1)

  df_out <- fix_date_cols(df_in, c("date", "not_a_column"))

  expect_s3_class(df_out$date, "Date")
  expect_equal(df_out$value, 1)

})

test_that("trim_exchange removes the exchange suffix", {

  expect_equal(trim_exchange("AAPL.US"), "AAPL")
  expect_equal(trim_exchange("AAPL"), "AAPL")
  expect_null(trim_exchange(NULL))

})

test_that("parse_api_df survives an absent body", {

  expect_equal(nrow(parse_api_df(NA_character_)), 0)
  expect_equal(nrow(parse_api_df(character(0))), 0)

})

test_that("get_eodhd keeps the parsed and the raw answer in separate caches", {

  skip_if_offline()
  skip_on_cran()
  skip_without_paid_token()

  suppressMessages({

    df_out <- get_eodhd("ust/yield-rates", list(`filter[year]` = 2026),
                        cache_folder = test_cache(), check_quota = FALSE)
    expect_s3_class(df_out, "tbl_df")

    # the second call asks for the raw list, and must not be served the tibble
    l_out <- get_eodhd("ust/yield-rates", list(`filter[year]` = 2026),
                       as_dataframe = FALSE,
                       cache_folder = test_cache(), check_quota = FALSE)
    expect_false(inherits(l_out, "tbl_df"))
    expect_type(l_out, "list")

  })
})
