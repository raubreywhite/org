# org 2022.7.21

- Reduction of exports to: initialize_project, set_results, write_text
- initialize_project now takes in `env` as an argument (the environment into which the functions will be sourced)

# org 2020.2.17

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

# org 2019.4.2

- Allows for multiple code folders to be sourced using the argument `folders_to_be_sourced` (previously this was hardcoded as a folder called `code`)

# org 2019.3.5

- Removal of stringr and lubridate dependencies

# org 2019.2.21

- Submission to CRAN
- Includes functions `AllowFileManipulationFromInitialiseProject` and `InitialiseProject`
