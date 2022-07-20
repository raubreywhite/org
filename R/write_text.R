convert_newline_linux_to_windows <- function(txt) {
  needs_converting <- length(grep("\\n", txt)) > 0 & length(grep("\\r\\n", txt)) == 0
  if (needs_converting) {
    txt <- gsub("\\n", "\r\n", txt)
  }
  return(txt)
}

#' Write text to a file
#' @param txt Text to be written
#' @param file File, passed through to `base::cat`
#' @param header Optional header that is inserted at the top of the text file
#' @return No return value.
#' @export
write_text <- function(txt, file = "", header = "**THIS FILE IS CONSTANTLY OVERWRITTEN -- DO NOT MANUALLY EDIT**\r\n\r\n") {
  header <- convert_newline_linux_to_windows(header)
  txt <- convert_newline_linux_to_windows(txt)

  retval <- paste0(header, txt)

  cat(retval, file = file)
}
