#' Extract package names referenced in R files
#'
#' Scans R files for `library()`, `require()`, and `pkg::` usage and returns
#' a character vector of unique package names.
#'
#' @param paths Character vector of file or directory paths. Directories are
#'   scanned for `.R` files.
#' @return A sorted character vector of unique package names.
#' @keywords internal
extract_packages <- function(paths) {
  files <- character(0)
  for (p in paths) {
    if (dir.exists(p)) {
      files <- c(files, list.files(p, pattern = "\\.[rR]$", full.names = TRUE))
    } else if (file.exists(p)) {
      files <- c(files, p)
    }
  }
  if (length(files) == 0) return(character(0))

  lines <- unlist(lapply(files, readLines, warn = FALSE))

  # library(pkg) and require(pkg) — with or without quotes
  lib_matches <- regmatches(
    lines,
    gregexpr("(?<=\\b(library|require)\\()[\"']?[a-zA-Z][a-zA-Z0-9.]*[\"']?", lines, perl = TRUE)
  )
  lib_pkgs <- gsub("[\"']", "", unlist(lib_matches))

  # pkg::fn and pkg:::fn
  ns_matches <- regmatches(
    lines,
    gregexpr("\\b[a-zA-Z][a-zA-Z0-9.]*(?=:::?)", lines, perl = TRUE)
  )
  ns_pkgs <- unlist(ns_matches)

  sort(unique(c(lib_pkgs, ns_pkgs)))
}

#' Find missing packages referenced in R files
#'
#' @param paths Character vector of file or directory paths to scan.
#' @return Character vector of missing package names.
#' @keywords internal
find_missing_packages <- function(paths) {
  pkgs <- extract_packages(paths)
  installed <- utils::installed.packages()[, "Package"]
  base_pkgs <- rownames(utils::installed.packages(priority = "base"))
  setdiff(pkgs, c(installed, base_pkgs))
}

#' Error if packages are missing
#'
#' @param paths Character vector of file or directory paths to scan.
#' @keywords internal
check_missing_packages <- function(paths) {
  missing <- find_missing_packages(paths)
  if (length(missing) > 0) {
    stop(
      "Missing packages: ", paste(missing, collapse = ", "),
      "\nRun with install_missing_packages = TRUE to install them.",
      call. = FALSE
    )
  }
}

#' Install missing packages referenced in R files
#'
#' @param paths Character vector of file or directory paths to scan.
#' @return Invisible character vector of packages that were installed.
#' @keywords internal
do_install_missing_packages <- function(paths) {
  missing <- find_missing_packages(paths)

  if (length(missing) == 0) {
    message("All packages already installed.")
    return(invisible(character(0)))
  }

  message("Installing missing packages: ", paste(missing, collapse = ", "))
  if (requireNamespace("pak", quietly = TRUE)) {
    pak::pak(missing)
  } else {
    utils::install.packages(missing)
  }

  invisible(missing)
}
