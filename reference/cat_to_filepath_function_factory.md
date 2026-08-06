# Create a function to write to a specific file

Creates a closure that writes to a specified file path. Use it to create
several functions that write to different files with the same behavior.

## Usage

``` r
cat_to_filepath_function_factory(filepath)
```

## Arguments

- filepath:

  The path to the file to write to.

## Value

A function that writes to the specified file. It takes these parameters:

- `...`: Content to write.

- `sep`: Separator between elements (default: "").

- `append`: Whether to append to existing content (default: TRUE).
