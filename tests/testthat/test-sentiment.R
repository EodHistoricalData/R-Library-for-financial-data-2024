test_that("sentiment and word weights", {

  skip_if_offline()
  skip_on_cran()
  skip_without_paid_token()

  suppressMessages({

    df_sentiment <- get_sentiments(c("AAPL.US", "BTC-USD.CC"),
                                   cache_folder = test_cache(),
                                   check_quota = FALSE)

    expect_true(nrow(df_sentiment) > 0)
    # the api answers one element per symbol -- the wrapper stacks them
    expect_true(all(c("symbol", "date", "count", "normalized") %in% names(df_sentiment)))
    expect_true(length(unique(df_sentiment$symbol)) > 1)

    df_words <- get_news_word_weights("AAPL", "US",
                                      cache_folder = test_cache(),
                                      check_quota = FALSE)
    expect_true(nrow(df_words) > 0)
    expect_type(df_words$weight, "double")

  })
})
