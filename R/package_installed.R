#' Check if a package is installed and optionally install it
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
  uninstalled <- pkgs[!pkg %in% pkgs]
  if (length(uninstalled) > 0 & install_if_missing) {
    utils::install.packages(uninstalled)
    pkgs <- utils::installed.packages()[,"Package"]
  }
  return(pkg %in% pkgs)
}
