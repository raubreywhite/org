# Project folder locations

An environment that stores the locations of folders used in the project.

## Usage

``` r
project
```

## Format

An environment containing the following elements:

- home:

  The folder containing 'Run.R' and 'R/'.

- results_today:

  The folder inside `results` with today's date.
  [`initialize_project()`](https://www.rwhite.no/org/reference/initialize_project.md)
  creates it.

## See also

[`vignette("org")`](https://www.rwhite.no/org/articles/org.md), whose
"Project structure" section describes the standard folders and the
additional-folder convention. `org` stores folders passed through `...`
here under their own names. This help page does not describe them
individually.

Other project setup:
[`initialize_project()`](https://www.rwhite.no/org/reference/initialize_project.md),
[`set_results()`](https://www.rwhite.no/org/reference/set_results.md)

## Examples

``` r
home <- file.path(tempdir(), "org_project_example")
dir.create(file.path(home, "R"), recursive = TRUE, showWarnings = FALSE)

proj <- org::initialize_project(
  home = home,
  results = file.path(home, "results"),
  data_raw = file.path(home, "data_raw")
)
#> You are NOT sourcing into .GlobalEnv. All functions will be sourced into an environment that is returned from this function.
#> Sourcing all code inside /tmp/RtmprgAcNR/org_project_example/R into 

# Every folder is now available from anywhere in the analysis
org::project$home
#> [1] "/tmp/RtmprgAcNR/org_project_example/"
org::project$results
#> [1] "/tmp/RtmprgAcNR/org_project_example/results/"
org::project$results_today
#> [1] "/tmp/RtmprgAcNR/org_project_example/results/2026-08-20/"
org::project$data_raw
#> [1] "/tmp/RtmprgAcNR/org_project_example/data_raw/"

unlink(home, recursive = TRUE)
```
