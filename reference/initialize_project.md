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
  results_subfolder = NULL,
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
  directory. A relative path, for example `"."` or `"./analysis"`, is
  relative to the working directory.

- results:

  The base folder for storing results. `initialize_project()` creates a
  subfolder with today's date, or the subfolder that `results_subfolder`
  names. You reach it at `org::project$results_today`.

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

- results_subfolder:

  `NULL`, or one relative path inside `results`, for example `"v01"` or
  `"null/sim_0003"`. If you give it, `initialize_project()` creates
  `<results>/<results_subfolder>/` and sets `results_today` to that
  folder. It then creates no folder with today's date. The path MUST NOT
  be absolute and MUST NOT contain `..`, and `results` MUST also be
  given. The default, `NULL`, gives the folder with today's date.

- ...:

  Additional named arguments for other project folders (e.g., data, raw,
  etc.).

## Value

An environment containing:

- All folder locations as named elements.

- `$env`: The environment that the code was sourced into.

- `$results_today`: Path to today's results folder, or to the folder
  that `results_subfolder` names.

## Details

`initialize_project()` performs the seven operations below, in this
order.

1.  Creates necessary directories if they do not exist.

2.  Sets up date-based results organization, or the named folder that
    `results_subfolder` gives. It deletes each empty folder in `results`
    whose name holds a `YYYY-MM-DD` date. It keeps today's folder and
    the folder of the current run.

3.  Handles path encoding for cross-platform compatibility.

4.  Stops if any file holds more code lines than `max_loc_per_file`.

5.  Stops if a package the code needs is missing, or installs it when
    `install_missing_packages` is `TRUE`.

6.  Sources all .R files from the specified directories, in the order
    that the section "Sourcing order" gives.

7.  Maintains a mirror of settings in
    [`org::project`](https://www.rwhite.no/org/reference/project.md).

## Sourcing order

`initialize_project()` sources the folders in the order of
`folders_to_be_sourced`. In each folder, it sources the .R files in the
order of their file names. The locale does not change this order.

The rule compares two names character by character, and it ignores case:

1.  The space and the ASCII punctuation come first, in this order: the
    space, then `` _-,;:!?.'"()[]{}@*/\&#%`^+<=>|~$ ``.

2.  The digits come next, from `0` to `9`.

3.  The letters come next, from `a` to `z`.

4.  A character that is not ASCII comes last, in the order of its UTF-8
    bytes.

If two names are equal when case is ignored, the name with a lower case
letter at the first difference comes first. A name that is the start of
a longer name comes first. For example, `_cfg.R`, `01_data.R`,
`get_data.R`, `get.R`, `Get.R` and `plot.R` are sourced in that order.

For names of ASCII characters, the rule gives the order that R 4.6.0
with ICU gives under the `en_US.UTF-8` locale.

## See also

[`vignette("org")`](https://www.rwhite.no/org/articles/org.md) for the
recommended project layout. Its "Team collaboration" section shows how
to give one folder several possible paths.

Other project setup:
[`project`](https://www.rwhite.no/org/reference/project.md),
[`set_results()`](https://www.rwhite.no/org/reference/set_results.md),
[`sort_for_sourcing()`](https://www.rwhite.no/org/reference/sort_for_sourcing.md)

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
#> Sourcing all code inside /tmp/RtmpGLbeQp/org_init_example/analysis3/R into 

# Folder locations, both on the returned environment and on org::project
proj$results_today # Today's results folder
#> [1] "/tmp/RtmpGLbeQp/org_init_example/results/2026-11-17/"
proj$raw # Raw data folder
#> [1] "/tmp/RtmpGLbeQp/org_init_example/raw/"
org::project$results_today
#> [1] "/tmp/RtmpGLbeQp/org_init_example/results/2026-11-17/"

# Everything in home/R/ has been sourced into `env`
proj$env$greet()
#> [1] "hello"

# A named results folder instead of a dated one
proj <- org::initialize_project(
  home = home,
  results = file.path(tempdir(), "org_init_example", "results"),
  results_subfolder = "v01"
)
#> You are NOT sourcing into .GlobalEnv. All functions will be sourced into an environment that is returned from this function.
#> Sourcing all code inside /tmp/RtmpGLbeQp/org_init_example/analysis3/R into 
proj$results_today
#> [1] "/tmp/RtmpGLbeQp/org_init_example/results/v01/"

unlink(file.path(tempdir(), "org_init_example"), recursive = TRUE)
```
