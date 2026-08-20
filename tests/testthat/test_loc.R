context("loc")

test_that("loc_per_file skips blank lines and comment-only lines", {
  f <- file.path(tempdir(), "org_loc_basic.R")
  writeLines(
    c(
      "# a comment",
      "",
      "   ",
      "x <- 1",
      "y <- 2 # a trailing comment, so this line counts"
    ),
    f
  )

  testthat::expect_equal(unname(org::loc_per_file(f)), 2L)
  unlink(f)
})

test_that("loc_per_file counts a line inside a multi-line string", {
  f <- file.path(tempdir(), "org_loc_string.R")
  writeLines(
    c(
      "x <- \"",
      "# this starts with a hash but sits inside a string",
      "still inside the string",
      "\"",
      "y <- 1"
    ),
    f
  )

  # None of the five lines is blank, and none is entirely a comment.
  testthat::expect_equal(unname(org::loc_per_file(f)), 5L)
  unlink(f)
})

test_that("loc_per_file treats roxygen lines as comments", {
  f <- file.path(tempdir(), "org_loc_roxygen.R")
  writeLines(
    c(
      "#' Title",
      "#'",
      "#' @param x A number.",
      "#' @export",
      "f <- function(x) x"
    ),
    f
  )

  testthat::expect_equal(unname(org::loc_per_file(f)), 1L)
  unlink(f)
})

test_that("loc_per_file counts an indented comment as a comment", {
  f <- file.path(tempdir(), "org_loc_indent.R")
  writeLines(
    c(
      "f <- function() {",
      "  # an indented comment",
      "  1",
      "}"
    ),
    f
  )

  testthat::expect_equal(unname(org::loc_per_file(f)), 3L)
  unlink(f)
})

test_that("loc_per_file handles an empty file and a comment-only file", {
  empty <- file.path(tempdir(), "org_loc_empty.R")
  file.create(empty)
  testthat::expect_equal(unname(org::loc_per_file(empty)), 0L)

  comments <- file.path(tempdir(), "org_loc_comments.R")
  writeLines(c("# one", "# two"), comments)
  testthat::expect_equal(unname(org::loc_per_file(comments)), 0L)

  unlink(c(empty, comments))
})

test_that("loc_per_file names each count after its file", {
  a <- file.path(tempdir(), "org_loc_a.R")
  b <- file.path(tempdir(), "org_loc_b.R")
  writeLines("x <- 1", a)
  writeLines(c("x <- 1", "y <- 2"), b)

  retval <- org::loc_per_file(c(a, b))
  testthat::expect_equal(names(retval), c(a, b))
  testthat::expect_equal(unname(retval), c(1L, 2L))

  # The name is the path even when the caller supplies its own names.
  named <- org::loc_per_file(c(primary = a))
  testthat::expect_equal(names(named), a)

  unlink(c(a, b))
})

test_that("loc_per_file measures the prefix in the same units as the parser", {
  # An ideographic space is three bytes and one character. A parser column and
  # a substr() index disagree about it, and the comment then looks like code.
  f <- file.path(tempdir(), "org_loc_wide_space.R")
  con <- file(f, "wb")
  writeBin(charToRaw("　# a comment behind a wide space\nx <- 1\n"), con)
  close(con)

  testthat::expect_equal(unname(org::loc_per_file(f)), 1L)
  unlink(f)
})

test_that("loc_per_file handles the awkward shapes of real R source", {
  d <- file.path(tempdir(), "org_loc_shapes")
  dir.create(d, showWarnings = FALSE)
  count <- function(name, content_bytes) {
    f <- file.path(d, name)
    con <- file(f, "wb")
    writeBin(charToRaw(content_bytes), con)
    close(con)
    unname(org::loc_per_file(f))
  }

  # A raw string carrying a line that starts with a hash.
  testthat::expect_equal(
    count("raw.R", "x <- r\"(\n# inside a raw string\n)\"\ny <- 1\n"),
    4L
  )
  # An escaped quote, then a real comment on its own line.
  testthat::expect_equal(
    count("escaped.R", "x <- \"a \\\" b\" # trailing\n# real\n"),
    1L
  )
  # No final newline.
  testthat::expect_equal(count("notrail.R", "# c\nx <- 1"), 1L)
  # CRLF line endings.
  testthat::expect_equal(count("crlf.R", "# c\r\nx <- 1\r\n\r\ny <- 2\r\n"), 2L)
  # A shebang is a comment.
  testthat::expect_equal(
    count("shebang.R", "#!/usr/bin/env Rscript\nx <- 1\n"),
    1L
  )
  # A comment between arguments of a call that spans lines.
  testthat::expect_equal(count("inner.R", "f(\n  1, # one\n  # two\n  2\n)\n"), 4L)

  unlink(d, recursive = TRUE)
})

test_that("loc_per_file errors on a file R cannot parse", {
  f <- file.path(tempdir(), "org_loc_broken.R")
  writeLines("x <- function( {", f)

  testthat::expect_error(org::loc_per_file(f), "cannot parse it")
  unlink(f)
})
