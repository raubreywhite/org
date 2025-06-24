strip_trailing_forwardslash <- function(x, encode_from = "UTF-8", encode_to = "latin1") {
  if (is.null(x)) {
    return(NULL)
  }
  retval <- sub("/$", "", x)

  if (requireNamespace("glue", quietly = TRUE)) {
    for (i in seq_along(retval)) retval[i] <- glue::glue(retval[i], .envir = parent.frame(n = 1))
  }
  if (.Platform$OS.type == "windows") {
    retval <- iconv(retval, from = encode_from, to = encode_to)
  }
  return(retval)
}

strip_and_then_add_trailing_forwardslash <- function(x, encode_from = "UTF-8", encode_to = "latin1") {
  retval <- strip_trailing_forwardslash(x, encode_from, encode_to)
  retval <- paste0(retval, "/")
  return(retval)
}

create_dir <- function(folder){
  dir.create(folder, showWarnings = FALSE, recursive = TRUE)
}

#' Construct file path from components
#'
#' Joins path components using forward slashes, ensuring proper path
#' formatting across operating systems. Handles multiple components and removes
#' any double slashes that might occur.
#'
#' @param ... Character vectors that will be concatenated with "/" as separator.
#' @return A character vector containing the constructed path.
#' @examples
#' org::path("home", "user", "data.csv")  # Returns "home/user/data.csv"
#' org::path("home//user", "data.csv")    # Returns "home/user/data.csv"
#' @export
path <- function(...){
  dots <- list(...)
  if(length(dots) > 1){
    retval <- do.call("paste0", list(dots, collapse="/"))
  } else {
    retval <- dots[[1]]
  }
  retval <- gsub("([^/])//", "\\1/", retval)
  return(retval)
}

ls_files_int <- function(
    path = ".",
    regexp = NULL
){
  if(path == "."){
    path <- getwd()
  } else if(length(grep("^\\./", path))){
    path <- gsub("^./",getwd(), path)
  }
  path <- normalizePath(path, mustWork = FALSE)
  retval <- list.files(path = path, pattern = regexp, full.names = T, include.dirs = T)
  # remove @eaDir
  eaDir_grep <- grep("@eaDir", retval)
  if(length(eaDir_grep) > 0){
    retval <- retval[-eaDir_grep]
  }
  return(retval)
}
ls_files_int_vectorized <- Vectorize(ls_files_int, vectorize.args = "path", USE.NAMES = FALSE)

#' List files and directories recursively
#'
#' This function is equivalent to the Unix `ls` command but works across platforms.
#' It can list files and directories matching a regular expression pattern.
#'
#' @param path A character vector of one or more paths to search
#' @param regexp A regular expression pattern to filter files/directories
#' @return A character vector of file and directory paths
#' @details
#' The function:
#' - Handles both single and multiple paths
#' - Supports regular expression filtering
#' - Removes system-specific directories (e.g., @eaDir)
#' - Returns full paths
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
#' @export
ls_files <- function(
    path = ".",
    regexp = NULL
    ){
  retval <- ls_files_int_vectorized(
    path = path,
    regexp = regexp
  )
  if(length(path) == 1 & !is.null(ncol(retval))){
    retval <- retval[,1]
  } else if(length(path) == 1 & is.list(retval)){
    retval <- retval[[1]]
  }
  return(retval)
}

#' Create a function to write to a specific file
#'
#' This function creates a closure that writes to a specified file path.
#' It's useful for creating multiple functions that write to different files
#' while maintaining consistent behavior.
#'
#' @param filepath The path to the file to write to
#' @return A function that writes to the specified file with parameters:
#'   - `...`: Content to write
#'   - `sep`: Separator between elements (default: "")
#'   - `append`: Whether to append to existing content (default: TRUE)
#' @keywords internal
cat_to_filepath_function_factory <- function(filepath){
  force(filepath)
  function(..., sep = "", append = TRUE){
    cat(..., file = filepath, sep = sep, append = append)
  }
}

#' Move a directory and its contents
#'
#' Moves a directory and all its contents to a new location.
#' Can optionally overwrite the destination if it already exists.
#'
#' @param from Source directory path.
#' @param to Destination directory path.
#' @param overwrite_to Whether to overwrite existing destination (default: FALSE).
#' @return Nothing. Creates the destination directory and moves all contents.
#' @details
#' The function:
#' - Creates the destination directory if it doesn't exist
#' - Copies all files and subdirectories recursively
#' - Removes the source directory after successful copy
#' - Fails if source doesn't exist or destination exists (unless overwrite_to=TRUE)
#' @examples
#' \dontrun{
#' # Move a directory
#' org::move_directory("old_dir", "new_dir")
#'
#' # Move and overwrite existing directory
#' org::move_directory("old_dir", "new_dir", overwrite_to = TRUE)
#' }
#' @export
move_directory <- function(from, to, overwrite_to = FALSE){
  stopifnot(length(from) == 1)
  stopifnot(length(to) == 1)
  if(file.exists(to) & !overwrite_to) stop(to, " already exists.")
  if(!dir.exists(from)) stop(from, " doesn't exist/isn't a directory")

  unlink(to, recursive = TRUE, force = TRUE)
  create_dir(to)

  file.copy(
    from = ls_files(from),
    to = to,
    recursive = T
  )

  unlink(strip_trailing_forwardslash(from), recursive = TRUE, force = TRUE)
}
