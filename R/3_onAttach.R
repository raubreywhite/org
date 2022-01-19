.onAttach <- function(libname, pkgname) {
  packageStartupMessage(paste0(
    "org ",
    utils::packageDescription("org")$Version,
    "\n",
    "https://docs.sykdomspulsen.no/org"
  ))
}
