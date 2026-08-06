# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working
with code in this repository.

## Package Overview

`org` is an R package that provides a framework for organizing research
projects. It manages three core components: - **Code**:
Version-controlled scripts (GitHub) - **Results**: Date-based organized
output files (typically Dropbox/shared storage) - **Data**: Raw input
data (local/secure storage)

The package centralizes project configuration in
[`org::project`](https://www.rwhite.no/org/reference/project.md)
environment with paths like `home`, `results`, `results_today`, and
custom folders.

## Development Commands

### Standard R Package Workflow

``` r
# Load package functions during development
devtools::load_all(".")

# Generate/update documentation from roxygen comments
devtools::document()

# Run package checks (basic)
devtools::check()

# REQUIRED: CRAN compliance check
R CMD check . --as-cran

# Build the package
devtools::build()

# Install the package
devtools::install()
```

### Testing

``` r
# Run tests
devtools::test()

# Run specific test file
testthat::test_file("tests/testthat/test_initialize_project.R")
```

### Documentation

``` r
# View pkgdown site locally
pkgdown::preview_site()

# Build pkgdown site
pkgdown::build_site()
```

### Version and Release

The package uses date-based versioning format `YYYY.M.D` (e.g.,
`2025.11.22` for November 22, 2025). When making changes:

1.  Update `Version:` in DESCRIPTION to YYYY.M.D format (remove leading
    zeroes). Do NOT write `YY.M.D` —
    `package_version("26.8.3") > package_version("2026.4.9")` is FALSE,
    so a two-digit year is a version DECREASE and R refuses the upgrade.
2.  Update NEWS.md with changes under the new version heading

## Code Organization

### Core Modules

**R/0_env.R**: - Defines
[`org::project`](https://www.rwhite.no/org/reference/project.md)
environment that stores all project paths - This is the central data
structure for the package

**R/initialize_project.R**: - Main user-facing function to set up
project structure - Contains helper functions for path validation and
setup - Sets up results folder with date-based subfolders

**R/create_project.R**: - Creates example Quarto projects - Provides
templates for users

**R/utils_files.R**: - File utility functions:
[`path()`](https://www.rwhite.no/org/reference/path.md),
[`ls_files()`](https://www.rwhite.no/org/reference/ls_files.md),
[`move_directory()`](https://www.rwhite.no/org/reference/move_directory.md),
[`write_text()`](https://www.rwhite.no/org/reference/write_text.md) -
Cross-platform path handling

**R/package_installed.R**: - Utility to check and optionally install
packages

**R/2_onLoad.R**, **R/3_onAttach.R**: - Package initialization hooks

### Key Design Patterns

1.  **Multiple Path Support**: Functions accept character vectors of
    paths and use the first existing one. This enables cross-platform
    team collaboration (e.g., different Mac/Linux/Windows paths).

2.  **Environment-based Configuration**:
    [`org::project`](https://www.rwhite.no/org/reference/project.md) is
    passed through functions to store and access configuration rather
    than using globals.

3.  **Path Normalization**: All paths are normalized to use forward
    slashes and trailing slashes where appropriate for consistency.

4.  **Date-based Results Organization**: Results automatically organize
    into `YYYY-MM-DD` subfolders under the results path.

## Testing Structure

- Single main test file: `tests/testthat/test_initialize_project.R`
- Tests cover project initialization with various path configurations
- Minimal test suite (expand as needed for new features)

## GitHub Actions Workflow

The package runs on: - **Push to main or develop branches** - **Pull
requests to main**

Workflow: `.github/workflows/check-and-deploy.yml` 1. R-CMD-check: Runs
`R CMD check . --as-cran` for CRAN compliance 2. pkgdown: Builds and
deploys documentation to GitHub Pages (main branch only)

**Note**: The pkgdown step installs the package with
[`devtools::install()`](https://devtools.r-lib.org/reference/install.html)
before building the site.

## Vignettes

Located in `vignettes/org.Rmd`. This is the comprehensive user guide
covering: - Project organization philosophy - Quick start examples -
Team collaboration patterns - Best practices for code, results, and
data - Function reference - Common workflows - Troubleshooting

Section headings use sentence case capitalization (not Title Case).

## Important Notes for CRAN Compliance

- Minimal dependencies: only imports `utils` (base R)
- Suggests: testthat, knitr, rmarkdown, rstudioapi, glue
- No deprecated functions or breaking changes without version bumps
- Documentation must be runnable examples (avoid `\dontrun{}`)
- Cross-platform path handling is critical (uses forward slashes)

## Related Repositories

This package is part of the broader `raubreywhite` ecosystem: -
Documentation at: <https://www.rwhite.no/org/> - Repository:
<https://github.com/raubreywhite/org>

## Licensing

This package is `MIT + file LICENSE`. Two files carry the licence and
they MUST agree with each other:

- `LICENSE` holds exactly two lines, `YEAR:` and `COPYRIGHT HOLDER:`.
  CRAN requires that shape for `MIT + file LICENSE`. Do not put the
  licence text there.
- `DESCRIPTION` `Authors@R` MUST name the same holder, with
  `role = "cph"`.

The copyright holder for this package is **Richard Aubrey White**.

**Check the year at the start of each calendar year, and whenever you
edit `DESCRIPTION`.** Nothing in `R CMD check` tests the copyright year,
so a stale one goes unnoticed indefinitely. A fleet sweep on 2026-08-06
found years of 2021, 2023 and 2025 still in place across 15 packages,
and not one package declared a `cph` role at all.

Check both in one step:

``` r
readLines("LICENSE")
a <- unclass(eval(parse(text = read.dcf("DESCRIPTION")[1, "Authors@R"])))
Filter(function(p) "cph" %in% p$role, a)
```
