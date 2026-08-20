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

  Character vectors to join with "/" as the separator. `path()` recycles
  them against each other, the same way
  [`base::file.path()`](https://rdrr.io/r/base/file.path.html) does, so
  one component of length 3 and one of length 1 give three paths.

## Value

A character vector containing the constructed path. It is `character(0)`
if any component has length zero.

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

# Components are recycled, so one call builds several paths
org::path("home", c("a.csv", "b.csv"))
#> [1] "home/a.csv" "home/b.csv"
```
