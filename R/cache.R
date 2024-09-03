#' Returns default cache folder
#'
#' @noRd
get_default_cache <- function() {

  return(fs::path_temp("eodhdR2-cache"))

}


#' Creates path of cache file
#'
#' @noRd
get_cache_file <- function(ticker, exchange, cache_folder, type_data) {

  f_out <- fs::path(
    cache_folder,
    glue::glue("{ticker}_{exchange}_eodhd_{type_data}.rds")
  )

  fs::dir_create(dirname(f_out), recurse = TRUE)

  return(f_out)
}

#' Writes file to cache using rds
#'
#' @noRd
write_cache <- function(x, f_out) {

  readr::write_rds(x, f_out)

  cli::cli_alert_info("cache file {basename(f_out)} saved")

  return(invisible(TRUE))

}

#' Reads file to cache from rds
#'
#' @noRd
read_cache <- function(f_cache) {

  cli::cli_alert_info("using local cache with file {basename(f_cache)}")

  x <- readr::read_rds(f_cache)

  return(x)
}
