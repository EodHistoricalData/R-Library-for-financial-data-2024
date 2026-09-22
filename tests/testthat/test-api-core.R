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

test_that("build_cache_name separates parameter sets that paste the same", {

  # the elements of a vector used to be pasted with "_", so a value that
  # already contains the separator could move the boundary without changing
  # the string
  expect_false(identical(
    build_cache_name("bulk", list(symbols = c("A_B", "C"))),
    build_cache_name("bulk", list(symbols = c("A", "B_C")))
  ))

  # one value against a vector that concatenates to it
  expect_false(identical(
    build_cache_name("bulk", list(symbols = "AB")),
    build_cache_name("bulk", list(symbols = c("A", "B")))
  ))

  # a value that ends where the next parameter's name begins
  expect_false(identical(
    build_cache_name("eod", list(a = "1", b = "2")),
    build_cache_name("eod", list(a = "1_b-2"))
  ))

  # the guard must not make equal inputs differ
  expect_identical(
    build_cache_name("bulk", list(symbols = c("A", "B"))),
    build_cache_name("bulk", list(symbols = c("A", "B")))
  )

  # the parameter names carry the separators too, so they are length prefixed
  # as well
  expect_false(identical(
    build_cache_name("eod", list(`a-1` = "1:1:x")),
    build_cache_name("eod", list(a = "1", `1:1:x` = character(0)))
  ))

  # a missing value must not read as the string "NA"
  expect_false(identical(
    build_cache_name("eod", list(a = NA_character_)),
    build_cache_name("eod", list(a = "NA"))
  ))

  # multibyte values: same character count, different characters, and a
  # composed character against its decomposed form
  expect_false(identical(
    build_cache_name("q", list(s = "\u00e9")),
    build_cache_name("q", list(s = "\u00e8"))
  ))
  expect_false(identical(
    build_cache_name("q", list(s = "\u00e9")),
    build_cache_name("q", list(s = "e\u0301"))
  ))

  # an emoji survives the trip without erroring
  expect_type(build_cache_name("q", list(s = "\U0001F600")), "character")

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

test_that("is_empty_body flags every shape of an empty answer", {

  # httr gives NA for an empty body and character(0) in some cases, while the
  # api answers "[]" or "{}" when nothing matched
  expect_true(is_empty_body(NA_character_))
  expect_true(is_empty_body(character(0)))
  expect_true(is_empty_body(NULL))
  expect_true(is_empty_body(""))
  expect_true(is_empty_body("[]"))
  expect_true(is_empty_body("{}"))

  # a body with data is not empty, and "" is only empty when it stands alone
  expect_false(is_empty_body('[{"a":1}]'))
  expect_false(is_empty_body('{"a":1}'))

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

test_that("get_eodhd accepts an endpoint written with a leading slash", {

  skip_if_offline()
  skip_on_cran()
  skip_without_paid_token()

  suppressMessages({

    # the base url and the endpoint are pasted with a slash between them, so a
    # caller who writes the endpoint the way the docs print it used to get a
    # double slash and a 404
    df_slash <- get_eodhd("/ust/yield-rates", list(`filter[year]` = 2026),
                          cache_folder = test_cache(), check_quota = FALSE)
    expect_s3_class(df_slash, "tbl_df")
    expect_gt(nrow(df_slash), 0)

  })
})

test_that("get_eodhd refuses a full url in place of an endpoint", {

  skip_on_cran()
  skip_without_paid_token()

  # a url would be pasted after the base one and produce a nonsense request
  # instead of an error the caller can read
  expect_error(
    get_eodhd("https://example.org/eod/AAPL.US",
              cache_folder = test_cache(), check_quota = FALSE),
    "path, not a url"
  )
  expect_error(
    get_eodhd("//example.org/eod/AAPL.US",
              cache_folder = test_cache(), check_quota = FALSE),
    "path, not a url"
  )

})
