# Extract package names referenced in R files

Scans R files for [`library()`](https://rdrr.io/r/base/library.html),
[`require()`](https://rdrr.io/r/base/library.html), and `pkg::` usage
and returns a character vector of unique package names.

## Usage

``` r
extract_packages(paths)
```

## Arguments

- paths:

  Character vector of file or directory paths. Directories are scanned
  for `.R` files.

## Value

A sorted character vector of unique package names.
