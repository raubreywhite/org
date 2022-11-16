.onAttach <- function(libname, pkgname) {
  version <- tryCatch(
    utils::packageDescription("org", fields = "Version"),
    warning = function(w){
      1
    }
  )

  packageStartupMessage(paste0(
    "org ",
    version,
    "\n",
    "https://www.csids.no/org/"
  ))
}
