#' Count the code lines in R files
#'
#' `loc_per_file()` counts the code lines in each file. A code line is a
#' physical line that is neither blank nor entirely a comment. The R parser
#' identifies the comments, so a `#` inside a string does not hide a line, and
#' a line inside a multi-line string still counts.
#'
#' @param paths A character vector of paths to R files.
#' @return A named integer vector, one element per path. Each name is the path,
#'   and each value is the number of code lines in that file.
#' @details
#' Three rules decide whether a line counts:
#' - A blank line does not count.
#' - A line holding only a comment does not count. Roxygen lines are comments.
#' - Every other line counts, including a line inside a multi-line string, and
#'   a line of code that ends with a comment.
#'
#' A regular expression alone cannot apply the second rule, because it cannot
#' tell a comment from a `#` inside a string. `loc_per_file()` reads the comment
#' positions from the parser instead, and it errors on a file that R cannot
#' parse.
#' @examples
#' f <- file.path(tempdir(), "org_loc_example.R")
#' writeLines(c(
#'   "# a comment, which does not count",
#'   "",
#'   "x <- 1 # a trailing comment, so the line counts",
#'   "y <- 2"
#' ), f)
#'
#' org::loc_per_file(f) # 2
#'
#' unlink(f)
#' @family file utilities
#' @seealso [initialize_project()], whose `max_loc_per_file` argument uses this
#'   function to stop a project that holds a file above the limit.
#' @export
loc_per_file <- function(paths) {
  retval <- vapply(paths, loc_one_file, integer(1), USE.NAMES = FALSE)
  names(retval) <- paths
  return(retval)
}

#' Count the code lines in one R file
#'
#' @param path Path to a single R file.
#' @return An integer.
#' @keywords internal
loc_one_file <- function(path) {
  lines <- readLines(path, warn = FALSE)
  if (length(lines) == 0) {
    return(0L)
  }

  # Parse the lines that were read, not the file a second time. Two reads can
  # see two different files, and a file-backed parse reports byte columns while
  # readLines() returns decoded characters.
  parsed <- tryCatch(
    parse(text = lines, keep.source = TRUE),
    error = function(e) {
      stop(
        "Cannot count the code lines in ",
        path,
        ", because R cannot parse it: ",
        conditionMessage(e),
        call. = FALSE
      )
    }
  )

  blank <- grepl("^[[:space:]]*$", lines)

  # A comment fills a line only when nothing but whitespace precedes it.
  # `x <- 1 # note` is a code line; `  # note` is not. Locate the comment by
  # its own text rather than by a column index, so the search and the prefix
  # are measured in the same units.
  parse_data <- utils::getParseData(parsed)
  comment_only <- rep(FALSE, length(lines))
  if (!is.null(parse_data) && nrow(parse_data) > 0) {
    comments <- parse_data[parse_data$token == "COMMENT", , drop = FALSE]
    for (i in seq_len(nrow(comments))) {
      line_number <- comments$line1[i]
      if (line_number > length(lines)) {
        next
      }
      line <- lines[line_number]
      position <- regexpr(comments$text[i], line, fixed = TRUE)
      if (position < 1) {
        next
      }
      before <- substr(line, 1, position - 1)
      if (grepl("^[[:space:]]*$", before)) {
        comment_only[line_number] <- TRUE
      }
    }
  }

  return(as.integer(sum(!blank & !comment_only)))
}

#' Error if any file holds more code lines than the limit
#'
#' @param paths Character vector of folder paths to check.
#' @param max_loc The maximum number of code lines a single file may hold.
#' @keywords internal
check_max_loc_per_file <- function(paths, max_loc) {
  if (is.null(max_loc) || identical(max_loc, Inf)) {
    return(invisible(NULL))
  }
  if (
    length(max_loc) != 1 ||
      !is.numeric(max_loc) ||
      is.na(max_loc) ||
      max_loc < 0 ||
      (is.finite(max_loc) && max_loc != round(max_loc))
  ) {
    stop(
      "max_loc_per_file must be one whole number that is zero or more, or Inf.",
      call. = FALSE
    )
  }

  if (length(paths) == 0) {
    return(invisible(NULL))
  }

  # The same pattern that source_to_environment() uses to pick the files it
  # sources. The gate MUST cover exactly the files that get sourced, so the two
  # patterns have to stay identical.
  files <- unlist(ls_files(paths, regexp = "\\.[rR]$"), use.names = FALSE)
  if (length(files) == 0) {
    return(invisible(NULL))
  }

  counts <- loc_per_file(files)
  over <- counts[counts > max_loc]
  if (length(over) > 0) {
    stop(
      "These files hold more than ",
      max_loc,
      " code lines:\n",
      paste0("  ", names(over), " (", over, ")", collapse = "\n"),
      "\nSplit them, or raise max_loc_per_file.",
      call. = FALSE
    )
  }

  return(invisible(NULL))
}
