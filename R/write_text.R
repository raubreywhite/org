convert_newline_linux_to_windows <- function(txt) {
  needs_converting <- length(grep("\\n", txt)) > 0 & length(grep("\\r\\n", txt)) == 0
  if (needs_converting) {
    txt <- gsub("\\n", "\r\n", txt)
  }
  return(txt)
}

#' Write text to file
#'
#' Writes text to a file, optionally including a header at the top of the file.
#' Text and header are converted from Linux newline format to Windows newline format before writing.
#'
#' @param txt A character string of text to be written to the file.
#' @param file A character string specifying the file path. Passed through to `base::cat`. 
#'   Default is an empty string, which writes to the console.
#' @param header An optional character string header to be inserted at the top of the text file. 
#'   Default is `**THIS FILE IS CONSTANTLY OVERWRITTEN -- DO NOT MANUALLY EDIT**\r\n\r\n`.
#' @return No return value. Called for its side effect of writing to a file.
#' @examples
#' \dontrun{
#' org::write_text("Sample text", "output.txt")
#' org::write_text("Another piece of text", "output.txt", "Custom Header\r\n\r\n")
#' }
#' @export
write_text <- function(txt, file = "", header = "**THIS FILE IS CONSTANTLY OVERWRITTEN -- DO NOT MANUALLY EDIT**\r\n\r\n") {
  header <- convert_newline_linux_to_windows(header)
  txt <- convert_newline_linux_to_windows(txt)

  retval <- paste0(header, txt)

  cat(retval, file = file)
}
