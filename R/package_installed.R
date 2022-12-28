#' Is a package installed?
#' @param pkg Package name.
#' @returns Boolean. True if package is installed, false if not.
#' @examples
#' org::package_installed("data.table")
#' @export
package_installed <- function(pkg){
  pkgs <- utils::installed.packages()[,"Package"]
  return(pkg %in% pkgs)
}
