# Version 2026.8.20

## A file-length limit for analysis projects

- `initialize_project()` takes `max_loc_per_file`. It stops with an error naming
  every .R file that holds more code lines than the limit. The check runs before
  the package check and before sourcing, so an oversized file stops the project
  without installing or running anything first. The default is `Inf`, which
  checks nothing. The argument otherwise takes one whole number of zero or more,
  and rejects anything else.
- `loc_per_file()` is new and exported. It counts the code lines in each file you
  give it. A code line is a physical line that is neither blank nor entirely a
  comment.
- The R parser identifies the comments, not a regular expression. A regular
  expression skips a line inside a string that starts with `#`, and it cannot
  separate a comment that follows code from a comment that fills the line.
  Measured across the 237 R files of the package fleet, the two approaches
  disagree on 11 of them. The largest gap is 203 lines, in a file that embeds an
  R template as a single string.

## Bug fix: a project with several source folders was never checked

- `initialize_project()` built its list of source folders with one
  `path(home, folders_to_be_sourced)` call. `path()` deparses a multi-element
  argument into the path, so two folders produced a single string ending in
  `c("x", "y")`, which matches no folder.
- Every check reading that list therefore saw nothing whenever
  `folders_to_be_sourced` held more than one folder. That silently disabled
  `check_missing_packages()`, and it would have disabled the new
  `max_loc_per_file` check in the same way.
- Sourcing was never affected. `source_to_environment()` loops over the folders
  and calls `path()` once per folder, which is the correct usage.
- `initialize_project()` now calls `path()` once per folder as well.
- `path()` itself is unchanged. It deparses a multi-element argument for every
  caller, not only this one.
- **This changes behaviour for a project with several source folders**, even at
  the default `max_loc_per_file = Inf`. Such a project was never checked for
  missing packages, and now it is. It can therefore stop, or install a package,
  where earlier versions did neither.

## Documentation

- The package now generates its documentation with roxygen2 8.0.0. `DESCRIPTION`
  carries `Config/roxygen2/version` in place of `RoxygenNote`.

# Version 2026.8.6

## Licensing

- `DESCRIPTION` `Authors@R` now declares **Richard Aubrey White** as the
  copyright holder, with `role = "cph"`. It declared none at all, and
  neither did any other package in the fleet. Nothing in `R CMD check`
  reports that.
- The copyright year is now 2026. It read 2025.
- `CLAUDE.md` now carries a Licensing section, so the year gets checked
  rather than silently ageing.

## Corrections

- The 2026.8.3 entry described the `set_results()` bug wrongly, on three
  counts. `is.na()` on an environment returns `logical(0)`, not `FALSE`. The
  surrounding `if` then stopped on a zero-length condition, so the environment
  never reached `dir.exists()`. The message was "argument is of length zero",
  not "invalid filename argument". `dir.exists()` does give the latter when it
  is called directly, which is where the string came from, but that path never
  ran. The entry is corrected.
- The same entry said multi-element character paths remain unsupported. They
  work. `set_results()` given two paths where only the second exists returns
  `NULL` and selects that one. It errors only when none of them exists. The
  sentence is removed.
- `ls_files()` was titled "List files and directories recursively". It does not
  recurse: it calls `list.files()` without `recursive = TRUE`. Given `top.R` and
  `sub/deep.R` it returns `sub` and `top.R`, and never finds `deep.R`.

## Documentation

- All roxygen prose in `R/`, plus `vignettes/org.Rmd`, `README.md` and
  `index.md`, now follows ASD-STE100 (Simplified Technical English). Every
  sentence in those files runs to 25 words or fewer. The change splits long
  sentences, prefers the active voice, and marks requirement levels with
  RFC-2119 keywords. No behaviour changed.
- Seven roxygen readings ran over 25 words and every one was a splitter merge,
  not a long sentence. The fields carried no terminal punctuation, so a sentence
  splitter ran through `@param` into `@return` and on into the next block's
  title. The longest such reading was 65 words; its longest real component was
  22. Adding the missing full stops fixed the grammar and the measurement.

# Version 2026.8.3

- Fixed `set_results()`, which failed with "argument is of length zero" whenever
  it was called after `initialize_project()`. `initialize_project()` stores the
  sourcing environment in `org::project$env`. The folder-creation loop applied
  `is.na()` to that environment. On an environment `is.na()` returns
  `logical(0)`, with a warning, rather than `FALSE`. The surrounding `if` then
  received a zero-length condition and stopped. Non-character entries are now
  skipped.
- Added runnable examples to `project` and `set_results()`, which previously had
  none.
- Replaced the `\dontrun{}` examples on `initialize_project()`,
  `move_directory()`, and `write_text()` with examples that run against
  `tempdir()`.
- Added `@family` cross-links (project setup; file utilities) and a `@seealso`
  pointing at `vignette("org")` to all seven exported objects.
- Added `index.md`, `pkgdown/`, and `Rplots.pdf` to `.Rbuildignore`.
# Version 2026.4.9

- Added `install_missing_packages` argument to `initialize_project()`. Scans
  `folders_to_be_sourced` for `library()`, `require()`, and `pkg::` usage.
  Errors on missing packages by default; set `install_missing_packages = TRUE`
  to auto-install via `pak` (falls back to `install.packages()`).
- Removed `package_installed()`.
- Removed `create_project_quarto_internal_results()` and
  `create_project_quarto_external_results()`.

# Version 2025.6.24

- Improved roxygen2 documentation formatting, grammar, and clarity across all exported functions.
- Enhanced parameter descriptions with better punctuation and consistency.
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

# Version 2025.3.10

- `package_installed` can now install packages if missing.

# Version 2024.6.5

- Fixed an error with org::initialize_project where "//" at the start of a path will be removed.

# Version 2022.12.28

- Inclusion of `create_project_quarto` that provides an example project of how to use `org` with [quarto](https://quarto.org/).
- Inclusion of file utility functions, such as `ls_files`, `move_file_or_dir`, `path`.
- Inclusion of utility function `package_installed`.

# Version 2022.7.21

- Reduction of exports to: initialize_project, set_results, write_text.
- initialize_project now takes in `env` as an argument (the environment into which the functions will be sourced).

# Version 2020.2.17

Introduction of:
- write_text
- initialize_project
- set_results
- org::project

Depreciation of:
- AllowFileManipulationFromInitialiseProject
- InitialiseProject
- PROJ
- set_shared

# Version 2019.4.2

- Allows for multiple code folders to be sourced using the argument `folders_to_be_sourced` (previously this was hardcoded as a folder called `code`)

# Version 2019.3.5

- Removal of stringr and lubridate dependencies

# Version 2019.2.21

- Submission to CRAN
- Includes functions `AllowFileManipulationFromInitialiseProject` and `InitialiseProject`
