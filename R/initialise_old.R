#' Set SHARED folder after initialization (depreciated)
#' @param SHARED A folder inside `SHARED` with today's date will be created and it will be accessible via `org::PROJ$SHARED_TODAY` (this is where you will store all of your results)
#' @export
set_shared <- function(SHARED) {
  .Deprecated("initialize")
  if (is.null(PROJ[["computer_id"]])) stop("not initialized")
  PROJ$SHARED <- SHARED[PROJ[["computer_id"]]]

  today <- format.Date(Sys.time(), "%Y-%m-%d")

  # Add SHARED_TODAY to PROJ
  if (is.null(PROJ$SHARED)) {
    PROJ$SHARED_TODAY <- NULL
  } else {
    PROJ$SHARED_TODAY <- file.path(PROJ$SHARED, today)
  }

  if (!CONFIG$ALLOW_FILE_MANIPULATION_FROM_INITIALISE_PROJECT) {
    warning("You need to run 'org::AllowFileManipulationFromInitialiseProject()' for this function to create today's folder (org::PROJ$SHARED_TODAY)")
  } else {
    for (i in names(PROJ)) {
      if (i == "computer_id") next
      if (!is.null(PROJ[[i]])) {
        if (!dir.exists(PROJ[[i]])) dir.create(PROJ[[i]], recursive = TRUE)
      }
    }

    # Delete empty folders in shared folder
    if (!is.null(PROJ$SHARED)) {
      for (f in list.files(PROJ$SHARED)) {
        if (grepl("[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]", f)) if (f == today) next # don't want to delete today's folder
        f2 <- file.path(PROJ$SHARED, f)
        if (file.exists(f2) && !dir.exists(f2)) next # dont delete files
        if (length(list.files(f2)) == 0) {
          unlink(f2, recursive = T)
        }
      }
    }
  }
}


#' Allows for InitialiseProject to create folders and
#' delete empty folders on your computer (depreciated)
#' @export AllowFileManipulationFromInitialiseProject
AllowFileManipulationFromInitialiseProject <- function() {
  .Deprecated("initialize")
  CONFIG$ALLOW_FILE_MANIPULATION_FROM_INITIALISE_PROJECT <- TRUE
}

#' Initialises project (depreciated)
#'
#' `org::InitialiseProject` takes in 2+ arguments.
#' It then saves its results (i.e. folder locations) in `org::PROJ`,
#' which you will use in all of your subsequent code.
#'
#' You need to run 'org::AllowFileManipulationFromInitialiseProject()'
#' for this function to create today's folder (org::PROJ$SHARED_TODAY).
#'
#' For more details see the help vignette:
#' \code{vignette("intro", package = "org")}
#' @param HOME The folder containing 'Run.R' and 'code/'
#' @param SHARED A folder inside `SHARED` with today's date will be created and it will be accessible via `org::PROJ$SHARED_TODAY` (this is where you will store all of your results)
#' @param folders_to_be_sourced The names of folders that live inside `HOME` and all .r and .R files inside it will be sourced into the global environment.
#' @param codes_absolute If `TRUE` then `folders_to_be_sourced` is an absolute folder reference. If `FALSE` then `folders_to_be_sourced` is relative and inside `HOME`.
#' @param encode_from Folders current encoding (only used on Windows)
#' @param encode_to Folders final encoding (only used on Windows)
#' @param ... Other folders that you would like to reference
#' @examples
#' \dontrun{
#' org::AllowFileManipulationFromInitialiseProject()
#' org::InitialiseProject(
#'   HOME = "/git/analyses/2019/analysis3/",
#'   SHARED = "/dropbox/analyses_results/2019/analysis3/",
#'   RAW = "/data/analyses/2019/analysis3/"
#' )
#' org::PROJ$SHARED_TODAY
#' org::PROJ$RAW
#' }
#' @export
InitialiseProject <- function(HOME = NULL,
                              SHARED = NULL,
                              folders_to_be_sourced = "code",
                              codes_absolute = FALSE,
                              encode_from = "UTF-8",
                              encode_to = "latin1",
                              ...) {
  .Deprecated("initialize")

  PROJ$HOME <- strip_trailing_forwardslash(HOME, encode_from = encode_from, encode_to = encode_to)
  PROJ$SHARED <- strip_trailing_forwardslash(SHARED, encode_from = encode_from, encode_to = encode_to)

  today <- format.Date(Sys.time(), "%Y-%m-%d")

  arguments <- list(...)
  for (i in seq_along(arguments)) {
    PROJ[[names(arguments)[i]]] <- strip_trailing_forwardslash(arguments[[i]], encode_from = encode_from, encode_to = encode_to)
  }

  # If multiple files were provided, then select the folder that exists
  for (i in names(PROJ)) {
    if (i == "computer_id") next
    if (!is.null(PROJ[[i]])) {
      if (i == "HOME") {
        PROJ[["computer_id"]] <- SelectFolderThatExists(PROJ[[i]], i)[["id"]]
      }
      PROJ[[i]] <- SelectFolderThatExists(PROJ[[i]], i)[["folder"]]
    }
  }

  # Add SHARED_TODAY to PROJ
  set_shared(SHARED = SHARED)

  if (!is.null(PROJ$HOME)) {
    setwd(PROJ$HOME)

    for (i in folders_to_be_sourced) {
      if (codes_absolute) {
        folder <- i
      } else {
        folder <- file.path(PROJ$HOME, i)
      }
      if (!dir.exists(folder)) {
        if (CONFIG$ALLOW_FILE_MANIPULATION_FROM_INITIALISE_PROJECT) {
          warning(paste0("Folder ", folder, " does not exist. Creating it now."))
          dir.create(folder)
        } else {
          warning(paste0("Folder ", folder, " does not exist."))
        }
      } else {
        message(paste0("Sourcing all code inside ", folder, " into .GlobalEnv"))
        fileSources <- file.path(folder, list.files(folder, pattern = "*.[rR]$"))

        if (CONFIG$rstudio) {
          # rstudio
          print(fileSources)
          sapply(fileSources, debugSource)
        } else {
          sapply(fileSources, source, .GlobalEnv)
        }
      }
    }
  }
}
