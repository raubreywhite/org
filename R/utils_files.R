create_dir <- function(folder){
  dir.create(folder, showWarnings = FALSE, recursive = TRUE)
}

#' Construct path to a file or directory
#' @param ... Character vectors that will be concatenated with "/" as a separator.
#' @export
path <- function(...){
  dots <- list(...)
  print(dots)
  retval <- do.call("paste0", list(dots, collapse="/"))
  retval <- gsub("//", "/", retval)
  return(retval)
}

ls_files_int <- function(
    path = ".",
    regexp = NULL
){
  if(path == "."){
    path <- getwd()
  } else if(length(grep("^./", path))){
    path <- gsub("^./",getwd(), path)
  }
  path <- normalizePath(path, mustWork = FALSE)
  list.files(path = path, pattern = regexp, full.names = T, include.dirs = T)
}

#' List files and directories
#' Equivalent to the unix `ls` command.
#' @param path A character vector of one or more paths.
#' @param regexp A regular expression that is passed to `list.files`.
#' @return filepaths and directory paths as a character vector
#' @export
ls_files <- Vectorize(ls_files_int, vectorize.args = "path")

cat_to_filepath_function_factory <- function(filepath){
  force(filepath)
  function(..., sep = "", append = TRUE){
    cat(..., file = filepath, sep = sep, append = append)
  }
}

#' Move one file or directory
#' @param from Filepath or directory path.
#' @param to Filepath or directory path.
#' @export
move_file_or_dir <- function(from, to){
  stopifnot(length(from) == 1)
  stopifnot(length(to) == 1)
  unlink(to, recursive = TRUE, force = TRUE)
  file.copy(from, to, recursive = TRUE)
  unlink(from, recursive = TRUE, force = TRUE)
}
