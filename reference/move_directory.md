# Move a directory and its contents

Moves a directory and all its contents to a new location. Can optionally
overwrite the destination if it already exists.

## Usage

``` r
move_directory(from, to, overwrite_to = FALSE)
```

## Arguments

- from:

  Source directory path.

- to:

  Destination directory path.

- overwrite_to:

  Whether to overwrite existing destination (default: FALSE).

## Value

Nothing. Creates the destination directory and moves all contents.

## Details

`move_directory()`:

- Creates the destination directory if it does not exist.

- Copies all files and subdirectories recursively.

- Removes the source directory after a successful copy.

- Fails if the source does not exist, or if the destination exists and
  `overwrite_to` is `FALSE`.

## See also

[`vignette("org")`](https://www.rwhite.no/org/articles/org.md), whose
"Function reference" section lists this alongside the other file
operations.

Other file utilities:
[`loc_per_file()`](https://www.rwhite.no/org/reference/loc_per_file.md),
[`ls_files()`](https://www.rwhite.no/org/reference/ls_files.md),
[`path()`](https://www.rwhite.no/org/reference/path.md),
[`write_text()`](https://www.rwhite.no/org/reference/write_text.md)

## Examples

``` r
from <- file.path(tempdir(), "org_move_from")
to <- file.path(tempdir(), "org_move_to")
dir.create(from, showWarnings = FALSE)
writeLines("first", file.path(from, "a.txt"))

# Move a directory
org::move_directory(from, to)
dir.exists(from) # FALSE, the source is gone
#> [1] FALSE
list.files(to) # "a.txt"
#> [1] "a.txt"

# Move and overwrite existing directory. The destination is replaced,
# not merged, so "a.txt" does not survive.
dir.create(from, showWarnings = FALSE)
writeLines("second", file.path(from, "b.txt"))
org::move_directory(from, to, overwrite_to = TRUE)
list.files(to) # "b.txt"
#> [1] "b.txt"

unlink(to, recursive = TRUE)
```
