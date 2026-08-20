# Initialize project environment and structure

`initialize_project()` initializes a new R project. It sets up folder
locations and sources code files. It creates a standardized project
structure with separate locations for code, results, and data. It
organizes results by date automatically, and it can source code from the
directories you specify.

## Usage

``` r
initialize_project(
  env = new.env(),
  home = NULL,
  results = NULL,
  folders_to_be_sourced = "R",
  max_loc_per_file = Inf,
  install_missing_packages = FALSE,
  source_folders_absolute = FALSE,
  encode_from = "UTF-8",
  encode_to = "latin1",
  ...
)
```

## Arguments

- env:

  The environment that `initialize_project()` sources the code into. Use
  `.GlobalEnv` to source code into the global environment. If you
  provide a different environment, all functions are sourced into that
  environment.

- home:

  The folder containing 'Run.R' and 'R/'. This is the main project
  directory.

- results:

  The base folder for storing results. `initialize_project()` creates a
  subfolder with today's date. You reach it at
  `org::project$results_today`.

- folders_to_be_sourced:

  Character vector of folder names inside `home`. These folders hold the
  .R files to source into the environment.

- max_loc_per_file:

  The maximum number of code lines a single .R file in
  `folders_to_be_sourced` may hold. `initialize_project()` stops with an
  error naming every file above the limit, before it sources any of
  them. A code line is a physical line that is neither blank nor
  entirely a comment, as counted by
  [`loc_per_file()`](https://www.rwhite.no/org/reference/loc_per_file.md).
  Default is `Inf`, which checks nothing.

- install_missing_packages:

  If `TRUE`, `initialize_project()` scans `folders_to_be_sourced` for
  package dependencies. It looks for
  [`library()`](https://rdrr.io/r/base/library.html),
  [`require()`](https://rdrr.io/r/base/library.html), and `pkg::` usage.
  It then installs any missing package with `pak` before it sources the
  code. If `pak` is not available, it falls back to
  [`install.packages()`](https://rdrr.io/r/utils/install.packages.html).
  Default is `FALSE`.

- source_folders_absolute:

  If `TRUE`, `initialize_project()` treats `folders_to_be_sourced` as
  absolute paths. If `FALSE`, the paths are relative to `home`.

- encode_from:

  Source encoding for file paths (only used on Windows).

- encode_to:

  Target encoding for file paths (only used on Windows).

- ...:

  Additional named arguments for other project folders (e.g., data, raw,
  etc.).

## Value

An environment containing:

- All folder locations as named elements.

- `$env`: The environment that the code was sourced into.

- `$results_today`: Path to today's results folder.

## Details

`initialize_project()` performs the seven operations below, in this
order.

1.  Creates necessary directories if they do not exist.

2.  Sets up date-based results organization.

3.  Handles path encoding for cross-platform compatibility.

4.  Stops if any file holds more code lines than `max_loc_per_file`.

5.  Stops if a package the code needs is missing, or installs it when
    `install_missing_packages` is `TRUE`.

6.  Sources all .R files from the specified directories.

7.  Maintains a mirror of settings in
    [`org::project`](https://www.rwhite.no/org/reference/project.md).

## See also

[`vignette("org")`](https://www.rwhite.no/org/articles/org.md) for the
recommended project layout. Its "Team collaboration" section shows how
to give one folder several possible paths.

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
#> Sourcing all code inside /tmp/RtmpAnpvuU/org_init_example/analysis3/R into 

# Folder locations, both on the returned environment and on org::project
proj$results_today # Today's results folder
#> [1] "/tmp/RtmpAnpvuU/org_init_example/results/2026-08-20/"
proj$raw # Raw data folder
#> [1] "/tmp/RtmpAnpvuU/org_init_example/raw/"
org::project$results_today
#> [1] "/tmp/RtmpAnpvuU/org_init_example/results/2026-08-20/"

# Everything in home/R/ has been sourced into `env`
proj$env$greet()
#> [1] "hello"

unlink(file.path(tempdir(), "org_init_example"), recursive = TRUE)
```
