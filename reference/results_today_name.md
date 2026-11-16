# Name of the results folder for this run, relative to `results`

Name of the results folder for this run, relative to `results`

## Usage

``` r
results_today_name(today, results_subfolder)
```

## Arguments

- today:

  Today's date as `YYYY-MM-DD`.

- results_subfolder:

  `NULL`, or a checked relative path.

## Value

`today` when `results_subfolder` is `NULL`, otherwise
`results_subfolder` without trailing slashes.
