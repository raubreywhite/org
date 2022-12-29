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

#' Set results folder after initialization
#' @param results A folder inside `results` with today's date will be created and it will be accessible via `org::project$results_today` (this is where you will store all of your results)
#' @param proj The project environment (default is `org::project`)
#' @returns Nothing. There is a side effect where the environments `proj` and `org::project` have the values $results and $results_today altered.
#' @export
set_results <- function(results, proj = org::project) {
  if (is.null(proj[["computer_id"]])) stop("not initialized")

  if(!identical(proj, project)){
    set_results_internal(results, proj)
  }
  set_results_internal(results, project)
}

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

#' Initializes project
#'
#' `org::initialize_project` takes in 2+ arguments.
#' It then saves folder locations in the return value (a new environment) and
#' in `org::project`, which you will use in all of your subsequent code. An additional
#' folder will be created on the user's file system (org::project$results_today) which
#' corresponds to `results/YYYY-MM-DD`. The sourced folders are saved into org::project$env.
#'
#' For more details see the help vignette:
#' \code{vignette("intro", package = "org")}
#' @param env The environment that the code will be sourced into (use `.GlobalEnv` to source code into the global environment)
#' @param home The folder containing 'Run.R' and 'R/'
#' @param results A folder inside `results` with today's date will be created and it will be accessible via `org::project$results_today` (this is where you will store all of your results)
#' @param folders_to_be_sourced The names of folders that live inside `home` and all .r and .R files inside it will be sourced into the global environment.
#' @param source_folders_absolute If `TRUE` then `folders_to_be_sourced` is an absolute folder reference. If `FALSE` then `folders_to_be_sourced` is relative and inside `home`.
#' @param encode_from Folders current encoding (only used on Windows)
#' @param encode_to Folders final encoding (only used on Windows)
#' @param ... Other folders that you would like to reference
#' @return Returns an environment that contains:
#'   - Folder locations
#'   - An environment called `env` into which the code has been sourced into.
#' There is also a side effect where `org::project` mirrors these values.
#' @examples
#' \donttest{
#' org::initialize_project(
#'   home = paste0(tempdir(), "/git/analyses/2019/analysis3/"),
#'   results = paste0(tempdir(), "/dropbox/analyses_results/2019/analysis3/"),
#'   raw = paste0(tempdir(), "/data/analyses/2019/analysis3/")
#' )
#' org::project$results_today
#' org::project$raw
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
