strip_trailing_forwardslash <- function(
  x,
  encode_from = "UTF-8",
  encode_to = "latin1"
) {
  if (is.null(x)) {
    return(NULL)
  }
  retval <- sub("/$", "", x)

  if (requireNamespace("glue", quietly = TRUE)) {
    for (i in seq_along(retval)) {
      retval[i] <- glue::glue(retval[i], .envir = parent.frame(n = 1))
    }
  }
  if (.Platform$OS.type == "windows") {
    retval <- iconv(retval, from = encode_from, to = encode_to)
  }
  return(retval)
}

strip_and_then_add_trailing_forwardslash <- function(
  x,
  encode_from = "UTF-8",
  encode_to = "latin1"
) {
  retval <- strip_trailing_forwardslash(x, encode_from, encode_to)
  retval <- paste0(retval, "/")
  return(retval)
}

create_dir <- function(folder) {
  dir.create(folder, showWarnings = FALSE, recursive = TRUE)
}

#' Construct file path from components
#'
#' Joins path components with forward slashes, so the path format is the same
#' across operating systems. Handles multiple components and removes any double
#' slashes that might occur.
#'
#' @param ... Character vectors to join with "/" as the separator.
#' @return A character vector containing the constructed path.
#' @examples
#' org::path("home", "user", "data.csv")  # Returns "home/user/data.csv"
#' org::path("home//user", "data.csv")    # Returns "home/user/data.csv"
#' @family file utilities
#' @seealso `vignette("org")`, whose "Path construction and cross-platform
#'   compatibility" section shows how this function is used in an analysis.
#' @export
path <- function(...) {
  dots <- list(...)
  if (length(dots) > 1) {
    retval <- do.call("paste0", list(dots, collapse = "/"))
  } else {
    retval <- dots[[1]]
  }
  retval <- gsub("([^/])//", "\\1/", retval)
  return(retval)
}

ls_files_int <- function(
  path = ".",
  regexp = NULL
) {
  if (path == ".") {
    path <- getwd()
  } else if (length(grep("^\\./", path))) {
    path <- gsub("^./", getwd(), path)
  }
  path <- normalizePath(path, mustWork = FALSE)
  retval <- list.files(
    path = path,
    pattern = regexp,
    full.names = T,
    include.dirs = T
  )
  # remove @eaDir
  eaDir_grep <- grep("@eaDir", retval)
  if (length(eaDir_grep) > 0) {
    retval <- retval[-eaDir_grep]
  }
  return(retval)
}
ls_files_int_vectorized <- Vectorize(
  ls_files_int,
  vectorize.args = "path",
  USE.NAMES = FALSE
)

#' List the files and directories directly inside a folder
#'
#' `ls_files()` is equivalent to the Unix `ls` command, and it works across
#' platforms. It can list files and directories that match a regular expression
#' pattern.
#'
#' @param path A character vector of one or more paths to search.
#' @param regexp A regular expression pattern to filter files and directories.
#' @return A character vector of file and directory paths.
#' @details
#' `ls_files()`:
#' - Handles both single and multiple paths.
#' - Supports regular expression filtering.
#' - Removes system-specific directories (e.g., @eaDir).
#' - Returns full paths.
#' @examples
#' \donttest{
#' # List all files in current directory
#' org::ls_files()
#'
#' # List only R files
#' org::ls_files(regexp = "\\.R$")
#'
#' # List files in multiple directories
#' org::ls_files(c("dir1", "dir2"))
#' }
#' @family file utilities
#' @seealso `vignette("org")`, whose "Troubleshooting" section uses this
#'   function to check which files a project will source.
#' @export
ls_files <- function(
  path = ".",
  regexp = NULL
) {
  retval <- ls_files_int_vectorized(
    path = path,
    regexp = regexp
  )
  if (length(path) == 1 & !is.null(ncol(retval))) {
    retval <- retval[, 1]
  } else if (length(path) == 1 & is.list(retval)) {
    retval <- retval[[1]]
  }
  return(retval)
}

#' Create a function to write to a specific file
#'
#' Creates a closure that writes to a specified file path. Use it to create
#' several functions that write to different files with the same behavior.
#'
#' @param filepath The path to the file to write to.
#' @return A function that writes to the specified file. It takes these
#'   parameters:
#'   - `...`: Content to write.
#'   - `sep`: Separator between elements (default: "").
#'   - `append`: Whether to append to existing content (default: TRUE).
#' @keywords internal
cat_to_filepath_function_factory <- function(filepath) {
  force(filepath)
  function(..., sep = "", append = TRUE) {
    cat(..., file = filepath, sep = sep, append = append)
  }
}

#' Move a directory and its contents
#'
#' Moves a directory and all its contents to a new location. Can optionally
#' overwrite the destination if it already exists.
#'
#' @param from Source directory path.
#' @param to Destination directory path.
#' @param overwrite_to Whether to overwrite existing destination (default: FALSE).
#' @return Nothing. Creates the destination directory and moves all contents.
#' @details
#' `move_directory()`:
#' - Creates the destination directory if it does not exist.
#' - Copies all files and subdirectories recursively.
#' - Removes the source directory after a successful copy.
#' - Fails if the source does not exist, or if the destination exists and
#'   `overwrite_to` is `FALSE`.
#' @examples
#' from <- file.path(tempdir(), "org_move_from")
#' to <- file.path(tempdir(), "org_move_to")
#' dir.create(from, showWarnings = FALSE)
#' writeLines("first", file.path(from, "a.txt"))
#'
#' # Move a directory
#' org::move_directory(from, to)
#' dir.exists(from) # FALSE, the source is gone
#' list.files(to) # "a.txt"
#'
#' # Move and overwrite existing directory. The destination is replaced,
#' # not merged, so "a.txt" does not survive.
#' dir.create(from, showWarnings = FALSE)
#' writeLines("second", file.path(from, "b.txt"))
#' org::move_directory(from, to, overwrite_to = TRUE)
#' list.files(to) # "b.txt"
#'
#' unlink(to, recursive = TRUE)
#' @family file utilities
#' @seealso `vignette("org")`, whose "Function reference" section lists this
#'   alongside the other file operations.
#' @export
move_directory <- function(from, to, overwrite_to = FALSE) {
  stopifnot(length(from) == 1)
  stopifnot(length(to) == 1)
  if (file.exists(to) & !overwrite_to) {
    stop(to, " already exists.")
  }
  if (!dir.exists(from)) {
    stop(from, " doesn't exist/isn't a directory")
  }

  unlink(to, recursive = TRUE, force = TRUE)
  create_dir(to)

  file.copy(
    from = ls_files(from),
    to = to,
    recursive = T
  )

  unlink(strip_trailing_forwardslash(from), recursive = TRUE, force = TRUE)
}
