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

The function:

- Creates the destination directory if it doesn't exist

- Copies all files and subdirectories recursively

- Removes the source directory after successful copy

- Fails if source doesn't exist or destination exists (unless
  overwrite_to=TRUE)

## Examples

``` r
if (FALSE) { # \dontrun{
# Move a directory
org::move_directory("old_dir", "new_dir")

# Move and overwrite existing directory
org::move_directory("old_dir", "new_dir", overwrite_to = TRUE)
} # }
```
