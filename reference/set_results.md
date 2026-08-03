# Set results folder after project initialization

Sets the results folder in the project environment and creates a
date-based subfolder. The date-based folder is accessible via
`proj$results_today` and empty date folders are automatically cleaned up
when new results are added.

## Usage

``` r
set_results(results, proj = org::project)
```

## Arguments

- results:

  A character vector specifying one or more possible results folder
  paths. The first existing path will be used.

- proj:

  The project environment. Default is
  [`org::project`](https://www.rwhite.no/org/reference/project.md).

## Value

Nothing. Modifies the `proj` environment to include:

- \$results:

  The base results folder path

- \$results_today:

  Path to today's results folder (format: YYYY-MM-DD)

## See also

[`vignette("org")`](https://www.rwhite.no/org/articles/org.md), whose
"Common workflows" section shows when to change the results folder after
a project is already initialized.

Other project setup:
[`initialize_project()`](https://www.rwhite.no/org/reference/initialize_project.md),
[`project`](https://www.rwhite.no/org/reference/project.md)

## Examples

``` r
home <- file.path(tempdir(), "org_set_results_example")
dir.create(file.path(home, "R"), recursive = TRUE, showWarnings = FALSE)

proj <- org::initialize_project(
  home = home,
  results = file.path(home, "results_a")
)
#> You are NOT sourcing into .GlobalEnv. All functions will be sourced into an environment that is returned from this function.
#> Sourcing all code inside /tmp/RtmpnMfP1f/org_set_results_example/R into 
org::project$results_today
#> [1] "/tmp/RtmpnMfP1f/org_set_results_example/results_a/2026-08-03/"

# Point the project at a different results folder
org::set_results(file.path(home, "results_b"))
org::project$results_today
#> [1] "/tmp/RtmpnMfP1f/org_set_results_example/results_b/2026-08-03/"
dir.exists(org::project$results_today)
#> [1] TRUE

unlink(home, recursive = TRUE)
```
