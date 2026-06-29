# Write text to file

Writes text to a file, optionally including a header at the top of the
file. Text and header are converted from Linux newline format to Windows
newline format before writing.

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

## Examples

``` r
if (FALSE) { # \dontrun{
org::write_text("Sample text", "output.txt")
org::write_text("Another piece of text", "output.txt", "Custom Header\r\n\r\n")
} # }
```
