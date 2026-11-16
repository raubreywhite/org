# A project folder `proj` inside `parent`, with two files in v01_functions.
make_relative_project <- function() {
  parent <- normalizePath(tempfile("org_rel_"), mustWork = FALSE)
  dir.create(file.path(parent, "proj", "v01_functions"), recursive = TRUE)
  writeLines(
    "f1 <- function() 1",
    file.path(parent, "proj", "v01_functions", "a.R")
  )
  writeLines(
    "f2 <- function() 2",
    file.path(parent, "proj", "v01_functions", "b.R")
  )
  return(parent)
}

# The names that initialize_project() sources into a new environment.
sourced_names <- function(home) {
  env <- new.env()
  suppressMessages(initialize_project(
    env = env,
    home = home,
    folders_to_be_sourced = "v01_functions"
  ))
  return(sort(ls(env)))
}

test_that("a relative home sources the same files as the absolute path", {
  parent <- make_relative_project()
  owd <- setwd(parent)
  on.exit(
    {
      setwd(owd)
      unlink(parent, recursive = TRUE)
    },
    add = TRUE
  )

  testthat::expect_identical(
    sourced_names(file.path(parent, "proj")),
    c("f1", "f2")
  )
  testthat::expect_identical(sourced_names("./proj"), c("f1", "f2"))
  testthat::expect_identical(sourced_names("./proj/"), c("f1", "f2"))
  testthat::expect_identical(sourced_names("proj/"), c("f1", "f2"))

  setwd(file.path(parent, "proj"))
  testthat::expect_identical(sourced_names("."), c("f1", "f2"))
  testthat::expect_identical(sourced_names("./"), c("f1", "f2"))
})

test_that("ls_files() lists the same files for ./x and the absolute path", {
  parent <- make_relative_project()
  owd <- setwd(parent)
  on.exit(
    {
      setwd(owd)
      unlink(parent, recursive = TRUE)
    },
    add = TRUE
  )
  absolute <- ls_files(file.path(parent, "proj", "v01_functions"))

  testthat::expect_length(absolute, 2L)
  testthat::expect_identical(ls_files("./proj/v01_functions"), absolute)
  testthat::expect_identical(ls_files("./proj/v01_functions/"), absolute)
  testthat::expect_identical(ls_files("proj/v01_functions"), absolute)
})

test_that("a home under ~ sources the same files as the absolute path", {
  testthat::skip_on_cran()
  testthat::skip_on_os("windows")
  parent <- make_relative_project()
  on.exit(unlink(parent, recursive = TRUE), add = TRUE)

  # HOME is set for the child process only.
  got <- run_org_child(
    c(
      "for (h in c('~/proj', '~/proj/')) {",
      "  e <- new.env()",
      "  suppressMessages(org::initialize_project(env = e, home = h, folders_to_be_sourced = 'v01_functions'))",
      "  cat(h, '=', paste(sort(ls(e)), collapse = ','), '\\n', file = out, sep = '', append = TRUE)",
      "}"
    ),
    "C",
    env = paste0("HOME=", parent)
  )
  testthat::expect_identical(got[-1], c("~/proj=f1,f2", "~/proj/=f1,f2"))
})
