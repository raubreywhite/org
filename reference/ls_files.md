# List the files and directories directly inside a folder

`ls_files()` is equivalent to the Unix `ls` command, and it works across
platforms. It can list files and directories that match a regular
expression pattern.

## Usage

``` r
ls_files(path = ".", regexp = NULL)
```

## Arguments

- path:

  A character vector of one or more paths to search.

- regexp:

  A regular expression pattern to filter files and directories.

## Value

A character vector of file and directory paths.

## Details

`ls_files()`:

- Handles both single and multiple paths.

- Supports regular expression filtering.

- Removes system-specific directories (e.g., @eaDir).

- Returns full paths.

## See also

[`vignette("org")`](https://www.rwhite.no/org/articles/org.md), whose
"Troubleshooting" section uses this function to check which files a
project will source.

Other file utilities:
[`move_directory()`](https://www.rwhite.no/org/reference/move_directory.md),
[`path()`](https://www.rwhite.no/org/reference/path.md),
[`write_text()`](https://www.rwhite.no/org/reference/write_text.md)

## Examples

``` r
# \donttest{
# List all files in current directory
org::ls_files()
#> [1] "/home/runner/work/org/org/docs/reference/cat_to_filepath_function_factory.html"
#> [2] "/home/runner/work/org/org/docs/reference/check_missing_packages.html"          
#> [3] "/home/runner/work/org/org/docs/reference/do_install_missing_packages.html"     
#> [4] "/home/runner/work/org/org/docs/reference/extract_packages.html"                
#> [5] "/home/runner/work/org/org/docs/reference/figures"                              
#> [6] "/home/runner/work/org/org/docs/reference/find_missing_packages.html"           
#> [7] "/home/runner/work/org/org/docs/reference/index.html"                           
#> [8] "/home/runner/work/org/org/docs/reference/initialize_project.html"              
#> [9] "/home/runner/work/org/org/docs/reference/initialize_project_folders.html"      

# List only R files
org::ls_files(regexp = "\\.R$")
#> character(0)

# List files in multiple directories
org::ls_files(c("dir1", "dir2"))
#> [[1]]
#> character(0)
#> 
#> [[2]]
#> character(0)
#> 
# }
```
