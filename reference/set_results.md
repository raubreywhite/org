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
