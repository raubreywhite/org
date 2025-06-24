#' Select first existing folder from a list
#'
#' @param folders Character vector of folder paths to check
#' @param name Name of the folder type for error messages
#' @return List with folder path and id
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
#' @param results Results folder path
#' @param proj Project environment
#' @keywords internal
set_results_internal <- function(results, proj){
  if(is.null(results)) return()
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
    if (i == "computer_id") next
    if (!is.null(proj[[i]]) & !is.na(proj[[i]])) {
      if (!dir.exists(proj[[i]])) dir.create(proj[[i]], showWarnings = FALSE, recursive = TRUE)
    }
  }

  # Delete empty folders in results folder
  if (!is.null(proj$results)) {
    for (f in list.files(proj$results)) {
      if (grepl("[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]", f)) {
        if (f == today) next # don't want to delete today's folder
        f2 <- file.path(proj$results, f)
        if (file.exists(f2) && !dir.exists(f2)) next # dont delete files
        if (length(list.files(f2)) == 0) {
          unlink(f2, recursive = T)
        }
      }
    }
  }
}

#' Set results folder after project initialization
#'
#' Sets the results folder in the project environment and creates a date-based subfolder.
#' The date-based folder is accessible via `proj$results_today` and empty date folders
#' are automatically cleaned up when new results are added.
#'
#' @param results A character vector specifying one or more possible results folder paths.
#'   The first existing path will be used.
#' @param proj The project environment. Default is `org::project`.
#' @return Nothing. Modifies the `proj` environment to include:
#'   \describe{
#'     \item{$results}{The base results folder path}
#'     \item{$results_today}{Path to today's results folder (format: YYYY-MM-DD)}
#'   }
#' @export
set_results <- function(results, proj = org::project) {
  if (is.null(proj[["computer_id"]])) stop("not initialized")

  if(!identical(proj, project)){
    set_results_internal(results, proj)
  }
  set_results_internal(results, project)
}

#' Initialize project folder structure
#'
#' @param env Environment to source code into
#' @param home Home directory path
#' @param results Results directory path
#' @param encode_from Source encoding
#' @param encode_to Target encoding
#' @param proj Project environment
#' @param ... Additional folder arguments
#' @keywords internal
initialize_project_folders <- function(
  env,
  home,
  results,
  encode_from,
  encode_to,
  proj,
  ...
){
  temp_env <- new.env()

  temp_env$home <- strip_and_then_add_trailing_forwardslash(home, encode_from = encode_from, encode_to = encode_to)
  if(!is.null(results)) temp_env$results <- strip_and_then_add_trailing_forwardslash(results, encode_from = encode_from, encode_to = encode_to)

  today <- format.Date(Sys.time(), "%Y-%m-%d")

  arguments <- list(...)
  for (i in seq_along(arguments)) {
    temp_env[[names(arguments)[i]]] <- strip_and_then_add_trailing_forwardslash(arguments[[i]], encode_from = encode_from, encode_to = encode_to)
  }

  # If multiple files were provided, then select the folder that exists
  for (i in names(temp_env)) {
    if (i == "computer_id") next
    if (!is.null(temp_env[[i]])) {
      if (i == "home") {
        temp_env[["computer_id"]] <- select_folder_that_exists(temp_env[[i]], i)[["id"]]
      }
      temp_env[[i]] <- select_folder_that_exists(temp_env[[i]], i)[["folder"]]
    }
  }

  # Add results_today to path
  set_results_internal(results = results, proj = temp_env)

  # copy temp_env to proj
  for(i in names(temp_env)){
    proj[[i]] <- temp_env[[i]]
  }
}

#' Source R files into environment
#'
#' @param proj Project environment
#' @param env Target environment for sourcing
#' @param folders_to_be_sourced Folders containing R files
#' @param source_folders_absolute Whether folder paths are absolute
#' @keywords internal
source_to_environment <- function(
  proj,
  env,
  folders_to_be_sourced,
  source_folders_absolute
){
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

    message(paste0("Sourcing all code inside ", folder, " into ", environmentName(env)))
    # fileSources <- file.path(folder, list.files(folder, pattern = "*.[rR]$"))
    file_sources <- ls_files(folder, regexp = "*.[rR]$")

    sapply(file_sources, source, env)
  }
}

#' Initialize project environment and structure
#'
#' This function initializes a new R project by setting up folder locations and sourcing code files.
#' It creates a standardized project structure with separate locations for code, results, and data.
#' Results are automatically organized by date, and code can be sourced from specified directories.
#'
#' @param env The environment that the code will be sourced into. Use `.GlobalEnv` to source code
#'           into the global environment. If a different environment is provided, all functions will
#'           be sourced into that environment.
#' @param home The folder containing 'Run.R' and 'R/'. This is the main project directory.
#' @param results The base folder for storing results. A subfolder with today's date will be created
#'                and accessible via `org::project$results_today`.
#' @param folders_to_be_sourced Character vector of folder names inside `home` containing .R files
#'                             to be sourced into the environment.
#' @param source_folders_absolute If `TRUE`, `folders_to_be_sourced` is treated as absolute paths.
#'                               If `FALSE`, paths are relative to `home`.
#' @param encode_from Source encoding for file paths (only used on Windows)
#' @param encode_to Target encoding for file paths (only used on Windows)
#' @param ... Additional named arguments for other project folders (e.g., data, raw, etc.)
#' @return An environment containing:
#'   - All folder locations as named elements
#'   - `$env`: The environment where code was sourced
#'   - `$results_today`: Path to today's results folder
#' @details
#' The function performs several key operations:
#' 1. Creates necessary directories if they don't exist
#' 2. Sets up date-based results organization
#' 3. Sources all .R files from specified directories
#' 4. Handles path encoding for cross-platform compatibility
#' 5. Maintains a mirror of settings in `org::project`
#' @examples
#' \dontrun{
#' # Initialize a new project
#' org::initialize_project(
#'   home = paste0(tempdir(), "/git/analyses/2019/analysis3/"),
#'   results = paste0(tempdir(), "/dropbox/analyses_results/2019/analysis3/"),
#'   raw = paste0(tempdir(), "/data/analyses/2019/analysis3/")
#' )
#'
#' # Access project settings
#' org::project$results_today  # Today's results folder
#' org::project$raw           # Raw data folder
#' }
#' @export
initialize_project <- function(
  env = new.env(),
  home = NULL,
  results = NULL,
  folders_to_be_sourced = "R",
  source_folders_absolute = FALSE,
  encode_from = "UTF-8",
  encode_to = "latin1",
  ...
  ) {

  stopifnot(!is.null(home))

  if(!identical(env, .GlobalEnv)){
    message("You are NOT sourcing into .GlobalEnv. All functions will be sourced into an environment that is returned from this function.")
  }

  proj <- new.env()
  for(p in c(project, proj)){
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
