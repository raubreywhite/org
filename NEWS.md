# Version 2025.3.10

- `package_installed` can now install packages if missing.

# Version 2024.6.5

- Fixed an error with org::initialize_project where "//" at the start of a path will be removed.

# Version 2022.12.28

- Inclusion of `create_project_quarto` that provides an example project of how to use `org` with [quarto](https://quarto.org/).
- Inclusion of file utility functions, such as `ls_files`, `move_file_or_dir`, `path`.
- Inclusion of utility function `package_installed`.

# Version 2022.7.21

- Reduction of exports to: initialize_project, set_results, write_text.
- initialize_project now takes in `env` as an argument (the environment into which the functions will be sourced).

# Version 2020.2.17

Introduction of:
- write_text
- initialize_project
- set_results
- org::project

Depreciation of:
- AllowFileManipulationFromInitialiseProject
- InitialiseProject
- PROJ
- set_shared

# Version 2019.4.2

- Allows for multiple code folders to be sourced using the argument `folders_to_be_sourced` (previously this was hardcoded as a folder called `code`)

# Version 2019.3.5

- Removal of stringr and lubridate dependencies

# Version 2019.2.21

- Submission to CRAN
- Includes functions `AllowFileManipulationFromInitialiseProject` and `InitialiseProject`
