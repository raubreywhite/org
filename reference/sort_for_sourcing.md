# Sort files into the order in which they are sourced

Sort files into the order in which they are sourced

## Usage

``` r
sort_for_sourcing(files)
```

## Arguments

- files:

  Paths to the files in one folder.

## Value

`files`, sorted by file name with the rule that
[`initialize_project()`](https://www.rwhite.no/org/reference/initialize_project.md)
documents. The locale does not change the result.
