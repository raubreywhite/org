# Run one org call in a child Rscript process under the locale `loc`.
# The child loads the same org as this session: the installed package under
# R CMD check, the source tree under devtools::test().
run_org_child <- function(code, loc, env = character()) {
  org_path <- getNamespaceInfo(asNamespace("org"), "path")
  installed <- file.exists(file.path(org_path, "Meta", "package.rds"))
  load_line <- if (installed) {
    sprintf(
      "suppressPackageStartupMessages(library(org, lib.loc = %s))",
      deparse(dirname(org_path))
    )
  } else {
    sprintf("pkgload::load_all(%s, quiet = TRUE)", deparse(org_path))
  }
  script <- tempfile(fileext = ".R")
  out <- tempfile(fileext = ".txt")
  writeLines(
    c(
      load_line,
      sprintf("out <- %s", deparse(out)),
      "cat('LOCALE=', Sys.getlocale('LC_COLLATE'), '\\n', file = out, sep = '')",
      code
    ),
    script
  )
  status <- system2(
    file.path(R.home("bin"), "Rscript"),
    script,
    env = c(
      paste0("LC_ALL=", loc),
      paste0("R_LIBS=", paste(.libPaths(), collapse = .Platform$path.sep)),
      env
    ),
    stdout = TRUE,
    stderr = TRUE
  )
  testthat::expect_true(
    file.exists(out),
    info = paste(status, collapse = "\n")
  )
  return(readLines(out))
}

# One file per name. Each file appends its own name to order.log when it is
# sourced.
write_order_files <- function(folder, names, log) {
  dir.create(folder, recursive = TRUE, showWarnings = FALSE)
  for (n in names) {
    writeLines(
      sprintf(
        "cat(%s, '\\n', file = %s, append = TRUE, sep = '')",
        deparse(n),
        deparse(log)
      ),
      file.path(folder, n)
    )
  }
  return(invisible(NULL))
}
