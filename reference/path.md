# Construct file path from components

Joins path components with forward slashes, so the path format is the
same across operating systems. Handles multiple components and removes
any double slashes that might occur.

## Usage

``` r
path(...)
```

## Arguments

- ...:

  Character vectors to join with "/" as the separator.

## Value

A character vector containing the constructed path.

## See also

[`vignette("org")`](https://www.rwhite.no/org/articles/org.md), whose
"Path construction and cross-platform compatibility" section shows how
this function is used in an analysis.

Other file utilities:
[`loc_per_file()`](https://www.rwhite.no/org/reference/loc_per_file.md),
[`ls_files()`](https://www.rwhite.no/org/reference/ls_files.md),
[`move_directory()`](https://www.rwhite.no/org/reference/move_directory.md),
[`write_text()`](https://www.rwhite.no/org/reference/write_text.md)

## Examples

``` r
org::path("home", "user", "data.csv")  # Returns "home/user/data.csv"
#> [1] "home/user/data.csv"
org::path("home//user", "data.csv")    # Returns "home/user/data.csv"
#> [1] "home/user/data.csv"
```
