#' Project folder locations
#'
#' An environment that stores the locations of folders used in the project.
#' @format An environment containing the following elements:
#' \describe{
#'   \item{home}{The folder containing 'Run.R' and 'R/'}
#'   \item{results_today}{The folder inside `results` with today's date, created by `initialize_project`}
#' }
#' @examples
#' home <- file.path(tempdir(), "org_project_example")
#' dir.create(file.path(home, "R"), recursive = TRUE, showWarnings = FALSE)
#'
#' proj <- org::initialize_project(
#'   home = home,
#'   results = file.path(home, "results"),
#'   data_raw = file.path(home, "data_raw")
#' )
#'
#' # Every folder is now available from anywhere in the analysis
#' org::project$home
#' org::project$results
#' org::project$results_today
#' org::project$data_raw
#'
#' unlink(home, recursive = TRUE)
#' @family project setup
#' @seealso `vignette("org")`, whose "Project structure" section describes the
#'   standard folders and the additional-folder convention. Folders passed
#'   through `...` are stored here under their own names and are not described
#'   individually.
#' @export project
project <- new.env()
