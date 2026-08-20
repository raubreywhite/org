#' Select first existing folder from a list
#'
#' @param folders Character vector of folder paths to check.
#' @param name Name of the folder type for error messages.
#' @return List with folder path and id.
#' @keywords internal
select_folder_that_exists <- function(folders, name) {
  retval <- NA
  id <- NA
  for (i in seq_along(folders)) {
    if (dir.exists(folders[i])) {
      retval <- folders[i]
      id <- i
      break
    }
  }

  # if multiple folders are provided, then they *must* exist
  if (is.na(retval) & length(folders) > 1) {
    stop(sprintf("Multiple folders provided to %s, but none exist", name))
  } else if (is.na(retval) & length(folders) == 1) {
    retval <- folders
    id <- 1
  }

  return(list(
    folder = retval,
    id = id
  ))
}

#' Internal function to set results folder
#'
#' @param results Results folder path.
#' @param proj Project environment.
#' @keywords internal
set_results_internal <- function(results, proj) {
  if (is.null(results)) {
    return()
  }
  proj$results <- strip_and_then_add_trailing_forwardslash(
    select_folder_that_exists(results, "results")[["folder"]]
  )

  today <- format.Date(Sys.time(), "%Y-%m-%d")

  # Add SHARED_TODAY to project
  if (is.null(proj$results)) {
    proj$results_today <- NULL
  } else {
    proj$results_today <- path(proj$results, today, "/")
  }

  for (i in names(proj)) {
    if (i == "computer_id") {
      next
    }
    # proj also holds non-path entries (e.g. `env`), which is.na() cannot test
    if (!is.character(proj[[i]])) {
      next
    }
    if (!is.na(proj[[i]])) {
      if (!dir.exists(proj[[i]])) {
        dir.create(proj[[i]], showWarnings = FALSE, recursive = TRUE)
      }
    }
  }

  # Delete empty folders in results folder
  if (!is.null(proj$results)) {
    for (f in list.files(proj$results)) {
      if (grepl("[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]", f)) {
        if (f == today) {
          next
        } # don't want to delete today's folder
        f2 <- file.path(proj$results, f)
        if (file.exists(f2) && !dir.exists(f2)) {
          next
        } # dont delete files
        if (length(list.files(f2)) == 0) {
          unlink(f2, recursive = T)
        }
      }
    }
  }
}

#' Set results folder after project initialization
#'
#' Sets the results folder in the project environment. Creates a date-based
#' subfolder. You reach the date-based folder at `proj$results_today`.
#' `set_results()` automatically cleans up empty date folders when new results
#' are added.
#'
#' @param results A character vector specifying one or more possible results
#'   folder paths. `set_results()` uses the first existing path.
#' @param proj The project environment. Default is `org::project`.
#' @return Nothing. Modifies the `proj` environment to include:
#'   \describe{
#'     \item{$results}{The base results folder path.}
#'     \item{$results_today}{Path to today's results folder. The format is YYYY-MM-DD.}
#'   }
#' @examples
#' home <- file.path(tempdir(), "org_set_results_example")
#' dir.create(file.path(home, "R"), recursive = TRUE, showWarnings = FALSE)
#'
#' proj <- org::initialize_project(
#'   home = home,
#'   results = file.path(home, "results_a")
#' )
#' org::project$results_today
#'
#' # Point the project at a different results folder
#' org::set_results(file.path(home, "results_b"))
#' org::project$results_today
#' dir.exists(org::project$results_today)
#'
#' unlink(home, recursive = TRUE)
#' @family project setup
#' @seealso `vignette("org")`, whose "Common workflows" section shows when to
#'   change the results folder after a project is already initialized.
#' @export
set_results <- function(results, proj = org::project) {
  if (is.null(proj[["computer_id"]])) {
    stop("not initialized")
  }

  if (!identical(proj, project)) {
    set_results_internal(results, proj)
  }
  set_results_internal(results, project)
}

#' Initialize project folder structure
#'
#' @param env Environment to source code into.
#' @param home Home directory path.
#' @param results Results directory path.
#' @param encode_from Source encoding.
#' @param encode_to Target encoding.
#' @param proj Project environment.
#' @param ... Additional folder arguments.
#' @keywords internal
initialize_project_folders <- function(
  env,
  home,
  results,
  encode_from,
  encode_to,
  proj,
  ...
) {
  temp_env <- new.env()

  temp_env$home <- strip_and_then_add_trailing_forwardslash(
    home,
    encode_from = encode_from,
    encode_to = encode_to
  )
  if (!is.null(results)) {
    temp_env$results <- strip_and_then_add_trailing_forwardslash(
      results,
      encode_from = encode_from,
      encode_to = encode_to
    )
  }

  today <- format.Date(Sys.time(), "%Y-%m-%d")

  arguments <- list(...)
  for (i in seq_along(arguments)) {
    temp_env[[names(arguments)[i]]] <- strip_and_then_add_trailing_forwardslash(
      arguments[[i]],
      encode_from = encode_from,
      encode_to = encode_to
    )
  }

  # If multiple files were provided, then select the folder that exists
  for (i in names(temp_env)) {
    if (i == "computer_id") {
      next
    }
    if (!is.null(temp_env[[i]])) {
      if (i == "home") {
        temp_env[["computer_id"]] <- select_folder_that_exists(
          temp_env[[i]],
          i
        )[["id"]]
      }
      temp_env[[i]] <- select_folder_that_exists(temp_env[[i]], i)[["folder"]]
    }
  }

  # Add results_today to path
  set_results_internal(results = results, proj = temp_env)

  # copy temp_env to proj
  for (i in names(temp_env)) {
    proj[[i]] <- temp_env[[i]]
  }
}

#' Source R files into environment
#'
#' @param proj Project environment.
#' @param env Target environment for the sourced code.
#' @param folders_to_be_sourced Folders containing R files.
#' @param source_folders_absolute Whether folder paths are absolute.
#' @keywords internal
source_to_environment <- function(
  proj,
  env,
  folders_to_be_sourced,
  source_folders_absolute
) {
  for (i in folders_to_be_sourced) {
    if (source_folders_absolute) {
      folder <- i
    } else {
      folder <- path(proj$home, i)
    }

    if (!dir.exists(folder)) {
      warning(paste0("Folder ", folder, " does not exist. Creating it now."))
      create_dir(folder)
    }

    message(paste0(
      "Sourcing all code inside ",
      folder,
      " into ",
      environmentName(env)
    ))
    # fileSources <- file.path(folder, list.files(folder, pattern = "*.[rR]$"))
    file_sources <- ls_files(folder, regexp = "*.[rR]$")

    sapply(file_sources, source, env)
  }
}

#' Initialize project environment and structure
#'
#' `initialize_project()` initializes a new R project. It sets up folder
#' locations and sources code files. It creates a standardized project
#' structure with separate locations for code, results, and data. It organizes
#' results by date automatically, and it can source code from the directories
#' you specify.
#'
#' @param env The environment that `initialize_project()` sources the code
#'   into. Use `.GlobalEnv` to source code into the global environment. If you
#'   provide a different environment, all functions are sourced into that
#'   environment.
#' @param home The folder containing 'Run.R' and 'R/'. This is the main project
#'   directory.
#' @param results The base folder for storing results. `initialize_project()`
#'   creates a subfolder with today's date. You reach it at
#'   `org::project$results_today`.
#' @param folders_to_be_sourced Character vector of folder names inside `home`.
#'   These folders hold the .R files to source into the environment.
#' @param max_loc_per_file The maximum number of code lines a single .R file in
#'   `folders_to_be_sourced` may hold. `initialize_project()` stops with an
#'   error naming every file above the limit, before it sources any of them.
#'   A code line is a physical line that is neither blank nor entirely a
#'   comment, as counted by [loc_per_file()]. Default is `Inf`, which checks
#'   nothing.
#' @param install_missing_packages If `TRUE`, `initialize_project()` scans
#'   `folders_to_be_sourced` for package dependencies. It looks for
#'   `library()`, `require()`, and `pkg::` usage. It then installs any missing
#'   package with `pak` before it sources the code. If `pak` is not available,
#'   it falls back to `install.packages()`. Default is `FALSE`.
#' @param source_folders_absolute If `TRUE`, `initialize_project()` treats
#'   `folders_to_be_sourced` as absolute paths. If `FALSE`, the paths are
#'   relative to `home`.
#' @param encode_from Source encoding for file paths (only used on Windows).
#' @param encode_to Target encoding for file paths (only used on Windows).
#' @param ... Additional named arguments for other project folders (e.g., data,
#'   raw, etc.).
#' @return An environment containing:
#'   - All folder locations as named elements.
#'   - `$env`: The environment that the code was sourced into.
#'   - `$results_today`: Path to today's results folder.
#' @details
#' `initialize_project()` performs the seven operations below, in this order.
#' 1. Creates necessary directories if they do not exist.
#' 2. Sets up date-based results organization.
#' 3. Handles path encoding for cross-platform compatibility.
#' 4. Stops if any file holds more code lines than `max_loc_per_file`.
#' 5. Stops if a package the code needs is missing, or installs it when
#'    `install_missing_packages` is `TRUE`.
#' 6. Sources all .R files from the specified directories.
#' 7. Maintains a mirror of settings in `org::project`.
#' @examples
#' # A minimal project: a home folder holding an R/ folder of functions
#' home <- file.path(tempdir(), "org_init_example", "analysis3")
#' dir.create(file.path(home, "R"), recursive = TRUE, showWarnings = FALSE)
#' writeLines("greet <- function() 'hello'", file.path(home, "R", "greet.R"))
#'
#' proj <- org::initialize_project(
#'   home = home,
#'   results = file.path(tempdir(), "org_init_example", "results"),
#'   raw = file.path(tempdir(), "org_init_example", "raw")
#' )
#'
#' # Folder locations, both on the returned environment and on org::project
#' proj$results_today # Today's results folder
#' proj$raw # Raw data folder
#' org::project$results_today
#'
#' # Everything in home/R/ has been sourced into `env`
#' proj$env$greet()
#'
#' unlink(file.path(tempdir(), "org_init_example"), recursive = TRUE)
#' @family project setup
#' @seealso `vignette("org")` for the recommended project layout. Its "Team
#'   collaboration" section shows how to give one folder several possible
#'   paths.
#' @export
initialize_project <- function(
  env = new.env(),
  home = NULL,
  results = NULL,
  folders_to_be_sourced = "R",
  max_loc_per_file = Inf,
  install_missing_packages = FALSE,
  source_folders_absolute = FALSE,
  encode_from = "UTF-8",
  encode_to = "latin1",
  ...
) {
  stopifnot(!is.null(home))

  if (!identical(env, .GlobalEnv)) {
    message(
      "You are NOT sourcing into .GlobalEnv. All functions will be sourced into an environment that is returned from this function."
    )
  }

  proj <- new.env()
  for (p in c(project, proj)) {
    initialize_project_folders(
      env = env,
      home = home,
      results = results,
      encode_from = encode_from,
      encode_to = encode_to,
      proj = p,
      ...
    )
  }

  # One call to path() per folder. path() deparses a multi-element argument into
  # the path itself, so path(home, c("x", "y")) returns one string ending in
  # `c("x", "y")`, and every check downstream then looks at a folder that does
  # not exist.
  source_folders <- if (source_folders_absolute) {
    folders_to_be_sourced
  } else {
    vapply(
      folders_to_be_sourced,
      function(folder) path(proj$home, folder),
      character(1),
      USE.NAMES = FALSE
    )
  }
  # Before the package check, so an oversized file stops the project without
  # installing anything first.
  check_max_loc_per_file(source_folders, max_loc_per_file)

  if (install_missing_packages) {
    do_install_missing_packages(source_folders)
  } else {
    check_missing_packages(source_folders)
  }

  source_to_environment(
    proj = proj,
    env = env,
    folders_to_be_sourced = folders_to_be_sourced,
    source_folders_absolute = source_folders_absolute
  )

  proj$env <- env
  project$env <- env

  return(proj)
}
