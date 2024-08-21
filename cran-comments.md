## R CMD check results

0 errors | 0 warnings | 0 note

* This is a new release.
* tested on [github action](https://github.com/EodHistoricalData/R-Library-for-financial-data-2024/actions), passing for windows (latest), macos (latest) and ubuntu (latest)

### Fixes for CRAN issues
* Fixed issue with api and package names in title and description. Now using single quote, e.g. `EODHD`
* Fixed issue with return value of function `parse_financials()`
* Added new person (copyright holder) and "ctr" tag for myself at DESCRIPTION: 

Authors@R: c(
  person(given = c("Marcelo", "S."),
        family = "Perlin",
        role = c("aut", "cre", "ctr"),
        email = "marceloperlin@gmail.com"),
  person(given = "Unicorn Data Services",
         role = "cph",
         email = "support@eodhistoricaldata.com")
  )
          
The copyright is also featured in the LICENSE file
