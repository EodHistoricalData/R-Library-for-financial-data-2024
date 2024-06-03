get_default_cache <- function() {
  return(fs::path_temp("eodhd2-cache"))
}

get_cache_file <- function(ticker, exchange, cache_folder, type_data) {

  f_out <- fs::path(
    cache_folder,
    glue::glue("{ticker}_{exchange}_eodhd_{type_data}.rds")
  )

  fs::dir_create(dirname(f_out), recurse = TRUE)

  return(f_out)
}

write_cache <- function(x, f_out) {

  readr::write_rds(x, f_out)

  return(invisible(TRUE))

}

read_cache <- function(f_cache) {

  x <- readr::read_rds(f_cache)

  return(x)
}
