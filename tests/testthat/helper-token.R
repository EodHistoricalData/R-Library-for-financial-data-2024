# Most of the endpoints wrapped in 2026 are not served to the demonstration
# token. Those tests run only when a real token is exported as EODHD_API_TOKEN,
# and are skipped otherwise (cran, github actions without secrets, and so on).

skip_without_paid_token <- function() {

  token <- Sys.getenv("EODHD_API_TOKEN")

  if (!nzchar(token)) {
    skip("no EODHD_API_TOKEN available -- skipping tests that need a paid token")
  }

  suppressMessages(set_token(token))

  invisible(token)

}

test_cache <- function() {
  fs::path(tempdir(), "eodhdR2-tests")
}
