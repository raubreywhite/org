# Construct file path from components

Joins path components using forward slashes, ensuring proper path
formatting across operating systems. Handles multiple components and
removes any double slashes that might occur.

## Usage

``` r
path(...)
```

## Arguments

- ...:

  Character vectors that will be concatenated with "/" as separator.

## Value

A character vector containing the constructed path.

## Examples

``` r
org::path("home", "user", "data.csv")  # Returns "home/user/data.csv"
#> [1] "home/user/data.csv"
org::path("home//user", "data.csv")    # Returns "home/user/data.csv"
#> [1] "home/user/data.csv"
```
