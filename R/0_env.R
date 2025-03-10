#' Folders to be used/referenced
#'
#' This environment is used to store the locations of folders that are used in the project.
#' @format An environment containing the following elements:
#' \describe{
#'  \item{home}{The folder containing 'Run.R' and 'R/'}
#'  \item{results_today}{The folder inside `results` with today's date, which is created by `initialize_project`}
#'  }
#' @export project
project <- new.env()
