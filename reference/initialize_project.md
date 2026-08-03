# Initialize project environment and structure

This function initializes a new R project by setting up folder locations
and sourcing code files. It creates a standardized project structure
with separate locations for code, results, and data. Results are
automatically organized by date, and code can be sourced from specified
directories.

## Usage

``` r
initialize_project(
  env = new.env(),
  home = NULL,
  results = NULL,
  folders_to_be_sourced = "R",
  install_missing_packages = FALSE,
  source_folders_absolute = FALSE,
  encode_from = "UTF-8",
  encode_to = "latin1",
  ...
)
```

## Arguments

- env:

  The environment that the code will be sourced into. Use `.GlobalEnv`
  to source code into the global environment. If a different environment
  is provided, all functions will be sourced into that environment.

- home:

  The folder containing 'Run.R' and 'R/'. This is the main project
  directory.

- results:

  The base folder for storing results. A subfolder with today's date
  will be created and accessible via `org::project$results_today`.

- folders_to_be_sourced:

  Character vector of folder names inside `home` containing .R files to
  be sourced into the environment.

- install_missing_packages:

  If `TRUE`, scans `folders_to_be_sourced` for package dependencies (via
  [`library()`](https://rdrr.io/r/base/library.html),
  [`require()`](https://rdrr.io/r/base/library.html), and `pkg::` usage)
  and installs any missing packages using `pak` before sourcing. Falls
  back to
  [`install.packages()`](https://rdrr.io/r/utils/install.packages.html)
  if `pak` is not available. Default is `FALSE`.

- source_folders_absolute:

  If `TRUE`, `folders_to_be_sourced` is treated as absolute paths. If
  `FALSE`, paths are relative to `home`.

- encode_from:

  Source encoding for file paths (only used on Windows)

- encode_to:

  Target encoding for file paths (only used on Windows)

- ...:

  Additional named arguments for other project folders (e.g., data, raw,
  etc.)

## Value

An environment containing:

- All folder locations as named elements

- `$env`: The environment where code was sourced

- `$results_today`: Path to today's results folder

## Details

The function performs several key operations:

1.  Creates necessary directories if they don't exist

2.  Sets up date-based results organization

3.  Sources all .R files from specified directories

4.  Handles path encoding for cross-platform compatibility

5.  Maintains a mirror of settings in
    [`org::project`](https://www.rwhite.no/org/reference/project.md)

## See also

[`vignette("org")`](https://www.rwhite.no/org/articles/org.md) for the
recommended project layout, and its "Team collaboration" section for
giving one folder several possible paths.

Other project setup:
[`project`](https://www.rwhite.no/org/reference/project.md),
[`set_results()`](https://www.rwhite.no/org/reference/set_results.md)

## Examples

``` r
# A minimal project: a home folder holding an R/ folder of functions
home <- file.path(tempdir(), "org_init_example", "analysis3")
dir.create(file.path(home, "R"), recursive = TRUE, showWarnings = FALSE)
writeLines("greet <- function() 'hello'", file.path(home, "R", "greet.R"))

proj <- org::initialize_project(
  home = home,
  results = file.path(tempdir(), "org_init_example", "results"),
  raw = file.path(tempdir(), "org_init_example", "raw")
)
#> You are NOT sourcing into .GlobalEnv. All functions will be sourced into an environment that is returned from this function.
#> Sourcing all code inside /tmp/RtmpnMfP1f/org_init_example/analysis3/R into 

# Folder locations, both on the returned environment and on org::project
proj$results_today # Today's results folder
#> [1] "/tmp/RtmpnMfP1f/org_init_example/results/2026-08-03/"
proj$raw # Raw data folder
#> [1] "/tmp/RtmpnMfP1f/org_init_example/raw/"
org::project$results_today
#> [1] "/tmp/RtmpnMfP1f/org_init_example/results/2026-08-03/"

# Everything in home/R/ has been sourced into `env`
proj$env$greet()
#> [1] "hello"

unlink(file.path(tempdir(), "org_init_example"), recursive = TRUE)
```
