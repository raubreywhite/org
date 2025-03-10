#' Check if a Package is Installed and Optionally Install it
#'
#' This function checks whether a specified package is installed in the current R environment.
#' Optionally, it can install the package if it is not already installed.
#'
#' @param pkg A character string specifying the name of the package to check.
#' @param install_if_missing A logical value indicating whether to install the package if it is not installed. Default is `FALSE`.
#' @return A logical value: `TRUE` if the package is installed (or successfully installed), `FALSE` otherwise.
#' @examples
#' \dontrun{
#' org::package_installed("data.table")
#' org::package_installed("ggplot2", install_if_missing = TRUE)
#' }
#' @export
package_installed <- function(pkg, install_if_missing = FALSE){
  pkgs <- utils::installed.packages()[,"Package"]
  if (!(pkg %in% pkgs) && install_if_missing) {
    utils::install.packages(pkg)
    pkgs <- utils::installed.packages()[,"Package"]
  }
  return(pkg %in% pkgs)
}
