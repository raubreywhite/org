# Write text to file

Writes text to a file. It can also insert a header at the top of the
file. `write_text()` converts the text and the header from Linux newline
format to Windows newline format before it writes.

## Usage

``` r
write_text(
  txt,
  file = "",
  header = "**THIS FILE IS CONSTANTLY OVERWRITTEN -- DO NOT MANUALLY EDIT**\r\n\r\n"
)
```

## Arguments

- txt:

  A character string of text to be written to the file.

- file:

  A character string specifying the file path. Passed through to
  [`base::cat`](https://rdrr.io/r/base/cat.html). Default is an empty
  string, which writes to the console.

- header:

  An optional character string header to be inserted at the top of the
  text file. Default is
  `**THIS FILE IS CONSTANTLY OVERWRITTEN -- DO NOT MANUALLY EDIT**\r\n\r\n`.

## Value

No return value. Called for its side effect of writing to a file.

## See also

[`vignette("org")`](https://www.rwhite.no/org/articles/org.md), whose
"Example project structure" section uses this function to keep a change
log beside the results.

Other file utilities:
[`loc_per_file()`](https://www.rwhite.no/org/reference/loc_per_file.md),
[`ls_files()`](https://www.rwhite.no/org/reference/ls_files.md),
[`move_directory()`](https://www.rwhite.no/org/reference/move_directory.md),
[`path()`](https://www.rwhite.no/org/reference/path.md)

## Examples

``` r
f <- file.path(tempdir(), "output.txt")

org::write_text("Sample text", f)
readLines(f, warn = FALSE)
#> [1] "**THIS FILE IS CONSTANTLY OVERWRITTEN -- DO NOT MANUALLY EDIT**"
#> [2] ""                                                               
#> [3] "Sample text"                                                    

# A custom header replaces the default one. The file is overwritten.
org::write_text("Another piece of text", f, "Custom Header\r\n\r\n")
readLines(f, warn = FALSE)
#> [1] "Custom Header"         ""                      "Another piece of text"

unlink(f)
```
