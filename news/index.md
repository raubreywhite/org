# Changelog

## Version 2026.4.9

CRAN release: 2026-04-09

- Added `install_missing_packages` argument to
  [`initialize_project()`](https://www.rwhite.no/org/reference/initialize_project.md).
  Scans `folders_to_be_sourced` for
  [`library()`](https://rdrr.io/r/base/library.html),
  [`require()`](https://rdrr.io/r/base/library.html), and `pkg::` usage.
  Errors on missing packages by default; set
  `install_missing_packages = TRUE` to auto-install via `pak` (falls
  back to
  [`install.packages()`](https://rdrr.io/r/utils/install.packages.html)).
- Removed `package_installed()`.
- Removed `create_project_quarto_internal_results()` and
  `create_project_quarto_external_results()`.

## Version 2025.6.24

- Improved roxygen2 documentation formatting, grammar, and clarity
  across all exported functions.
- Enhanced parameter descriptions with better punctuation and
  consistency.
- Updated function titles to be more concise and direct.
- Significantly expanded and improved the package vignette with:
  - Enhanced introduction explaining why to use `org`
  - Installation instructions for CRAN and GitHub
  - Quick start section for new users
  - Team collaboration examples showing multiple path usage
  - Comprehensive function reference organized by category
  - Common workflows and practical examples
  - Cross-platform path construction guidance
  - Troubleshooting section with solutions to common issues
  - Better formatting and organization throughout

## Version 2025.3.10

- `package_installed` can now install packages if missing.

## Version 2024.6.5

CRAN release: 2024-06-04

- Fixed an error with org::initialize_project where “//” at the start of
  a path will be removed.

## Version 2022.12.28

- Inclusion of `create_project_quarto` that provides an example project
  of how to use `org` with [quarto](https://quarto.org/).
- Inclusion of file utility functions, such as `ls_files`,
  `move_file_or_dir`, `path`.
- Inclusion of utility function `package_installed`.

## Version 2022.7.21

CRAN release: 2022-07-20

- Reduction of exports to: initialize_project, set_results, write_text.
- initialize_project now takes in `env` as an argument (the environment
  into which the functions will be sourced).

## Version 2020.2.17

Introduction of: - write_text - initialize_project - set_results -
org::project

Depreciation of: - AllowFileManipulationFromInitialiseProject -
InitialiseProject - PROJ - set_shared

## Version 2019.4.2

CRAN release: 2019-04-02

- Allows for multiple code folders to be sourced using the argument
  `folders_to_be_sourced` (previously this was hardcoded as a folder
  called `code`)

## Version 2019.3.5

- Removal of stringr and lubridate dependencies

## Version 2019.2.21

CRAN release: 2019-03-06

- Submission to CRAN
- Includes functions `AllowFileManipulationFromInitialiseProject` and
  `InitialiseProject`
