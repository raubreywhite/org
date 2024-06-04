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

#' Construct path to a file or directory
#' @param ... Character vectors that will be concatenated with "/" as a separator.
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

#' List files and directories
#' Equivalent to the unix `ls` command.
#' @param path A character vector of one or more paths.
#' @param regexp A regular expression that is passed to `list.files`.
#' @return filepaths and directory paths as a character vector
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

cat_to_filepath_function_factory <- function(filepath){
  force(filepath)
  function(..., sep = "", append = TRUE){
    cat(..., file = filepath, sep = sep, append = append)
  }
}

#' Move directory
#' @param from Filepath or directory path.
#' @param to Filepath or directory path.
#' @param overwrite_to Boolean.
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
