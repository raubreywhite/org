# Sort files into the order in which org sources them

`sort_for_sourcing()` sorts file paths into the order in which
[`initialize_project()`](https://www.rwhite.no/org/reference/initialize_project.md)
sources the .R files of one folder. The locale does not change the
result.

## Usage

``` r
sort_for_sourcing(files)
```

## Arguments

- files:

  A character vector of file paths or file names.

## Value

`files`, in sourcing order. Only the file name, `basename(files)`, sets
the order. Two paths with the same file name keep the order of their
full paths.

## Details

The rule compares the file names character by character, with case
ignored. Punctuation comes first (`_` before `-` before `.`), then
digits, then letters. A character that is not ASCII comes last, in the
order of its UTF-8 bytes. If two names are equal with case ignored, the
name with a lower case letter at the first difference comes first. The
section "Sourcing order" in
[`initialize_project()`](https://www.rwhite.no/org/reference/initialize_project.md)
gives the full rule.

## See also

Other project setup:
[`initialize_project()`](https://www.rwhite.no/org/reference/initialize_project.md),
[`project`](https://www.rwhite.no/org/reference/project.md),
[`set_results()`](https://www.rwhite.no/org/reference/set_results.md)

## Examples

``` r
org::sort_for_sourcing(c(
  "R/plot.R", "R/Get.R", "R/get.R", "R/get_data.R", "R/01_data.R",
  "R/_cfg.R"
))
#> [1] "R/_cfg.R"     "R/01_data.R"  "R/get_data.R" "R/get.R"      "R/Get.R"     
#> [6] "R/plot.R"    
# "R/_cfg.R" "R/01_data.R" "R/get_data.R" "R/get.R" "R/Get.R" "R/plot.R"
```
