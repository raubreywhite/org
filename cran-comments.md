# Submission

This is version 2026.11.18. CRAN has version 2026.4.9. The changes since 2026.4.9 are below, and `NEWS.md` gives the details.

## Changes since 2026.4.9

* `initialize_project()` sources the .R files in each folder in one fixed order, which the locale does not change. Earlier versions used the order of the locale. Under a locale other than `en_US.UTF-8`, for example `C`, the order can change.
* Bug fix: `initialize_project()` sourced nothing when `home` started with `./`, for example `"."`. `ls_files()` dropped the `/` after the working directory.
* `initialize_project()` takes `results_subfolder`, a named results folder that replaces the folder with today's date.
* A change for the lint gate. Five error and warning conditions no longer show the call that raised them, because they use `call. = FALSE`. Behaviour does not otherwise change.
* `initialize_project()` takes `max_loc_per_file`, and `loc_per_file()` is new.
* Bug fixes in these three places:
  * `path()`, for a component with more than one element.
  * `set_results()`, after `initialize_project()`.
  * The pattern that selects the .R files to source.

## Test environments

* Local Ubuntu 22.04.5 LTS, x86_64-pc-linux-gnu, R 4.6.0 (2026-04-24), session charset UTF-8.

## R CMD check results

`devtools::check(args = c("--no-manual", "--as-cran"))` with `_R_CHECK_CRAN_INCOMING_=false`:

0 errors | 0 warnings | 0 notes

## Downstream dependencies

None. `tools::package_dependencies("org", reverse = TRUE)` against CRAN, for Depends, Imports, LinkingTo and Suggests, gave none on 2026-11-16. So there was no reverse-dependency check to run.
