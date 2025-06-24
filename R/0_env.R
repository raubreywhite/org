#' Project folder locations
#'
#' An environment that stores the locations of folders used in the project.
#' @format An environment containing the following elements:
#' \describe{
#'   \item{home}{The folder containing 'Run.R' and 'R/'}
#'   \item{results_today}{The folder inside `results` with today's date, created by `initialize_project`}
#' }
#' @export project
project <- new.env()
