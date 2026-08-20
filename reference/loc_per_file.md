# Count the code lines in R files

`loc_per_file()` counts the code lines in each file. A code line is a
physical line that is neither blank nor entirely a comment. The R parser
identifies the comments, so a `#` inside a string does not hide a line,
and a line inside a multi-line string still counts.

## Usage

``` r
loc_per_file(paths)
```

## Arguments

- paths:

  A character vector of paths to R files.

## Value

A named integer vector, one element per path. Each name is the path, and
each value is the number of code lines in that file.

## Details

Three rules decide whether a line counts:

- A blank line does not count.

- A line holding only a comment does not count. Roxygen lines are
  comments.

- Every other line counts, including a line inside a multi-line string,
  and a line of code that ends with a comment.

A regular expression alone cannot apply the second rule, because it
cannot tell a comment from a `#` inside a string. `loc_per_file()` reads
the comment positions from the parser instead, and it errors on a file
that R cannot parse.

## See also

[`initialize_project()`](https://www.rwhite.no/org/reference/initialize_project.md),
whose `max_loc_per_file` argument uses this function to stop a project
that holds a file above the limit.

Other file utilities:
[`ls_files()`](https://www.rwhite.no/org/reference/ls_files.md),
[`move_directory()`](https://www.rwhite.no/org/reference/move_directory.md),
[`path()`](https://www.rwhite.no/org/reference/path.md),
[`write_text()`](https://www.rwhite.no/org/reference/write_text.md)

## Examples

``` r
f <- file.path(tempdir(), "org_loc_example.R")
writeLines(c(
  "# a comment, which does not count",
  "",
  "x <- 1 # a trailing comment, so the line counts",
  "y <- 2"
), f)

org::loc_per_file(f) # 2
#> /tmp/RtmpypJEnK/org_loc_example.R 
#>                                 2 

unlink(f)
```
