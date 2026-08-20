context("initialize")

test_that("Create org::project$results_today", {
  initialize_project(
    env = .GlobalEnv,
    home = tempdir(),
    results = tempdir(),
    raw = tempdir(),
    folders_to_be_sourced = NULL
  )

  testthat::expect_equal(TRUE, dir.exists(org::project$results_today))
})

test_that("Error due to multiple non-existed folders", {
  testthat::expect_error(
    initialize_project(
      env = .GlobalEnv,
      home = c("dfsdfoij323423", "sdfd232323"),
      results = tempdir(),
      raw = tempdir()
    )
  )
})


test_that("Works due to multiple non-existed folders", {
  initialize_project(
    env = .GlobalEnv,
    home = c(tempdir(), "sdfd232323"),
    results = tempdir(),
    raw = tempdir(),
    folders_to_be_sourced = NULL
  )

  testthat::expect_equal(TRUE, dir.exists(org::project$results_today))
})


test_that("computer_id identifying correct order", {
  initialize_project(
    env = .GlobalEnv,
    home = c("sdfd232323", tempdir()),
    results = tempdir(),
    raw = tempdir(),
    folders_to_be_sourced = NULL
  )

  testthat::expect_equal(2, org::project$computer_id)
})

test_that("Sources multiple code folders that do exist", {
  dir.create(file.path(tempdir(), "x1"))
  dir.create(file.path(tempdir(), "y1"))

  testthat::expect_message(
    initialize_project(
      env = .GlobalEnv,
      home = tempdir(),
      raw = tempdir(),
      folders_to_be_sourced = c("x1", "y1")
    ),
    "*Sourcing all code inside*"
  )
})

test_that("max_loc_per_file stops the project before it sources anything", {
  home <- file.path(tempdir(), "org_loc_project")
  unlink(home, recursive = TRUE, force = TRUE)
  dir.create(file.path(home, "R"), recursive = TRUE, showWarnings = FALSE)
  writeLines(rep("x <- 1", 1001), file.path(home, "R", "big.R"))
  writeLines("sentinel <- TRUE", file.path(home, "R", "a_small.R"))

  target <- new.env()
  testthat::expect_error(
    initialize_project(
      env = target,
      home = home,
      folders_to_be_sourced = "R",
      max_loc_per_file = 1000
    ),
    "big\\.R"
  )

  # The gate must run before sourcing, so the small file must not have run
  # either, even though it is well under the limit and sorts first.
  testthat::expect_false(exists("sentinel", envir = target, inherits = FALSE))

  unlink(home, recursive = TRUE, force = TRUE)
})

test_that("max_loc_per_file names every oversized file, in every folder", {
  home <- file.path(tempdir(), "org_loc_multi")
  unlink(home, recursive = TRUE, force = TRUE)
  dir.create(file.path(home, "x"), recursive = TRUE, showWarnings = FALSE)
  dir.create(file.path(home, "y"), recursive = TRUE, showWarnings = FALSE)
  writeLines(rep("x <- 1", 1001), file.path(home, "x", "big_first.R"))
  writeLines(rep("x <- 1", 1001), file.path(home, "y", "big_second.R"))

  # An implementation that checked only one folder, or reported only the first
  # offender, would fail one of these two expectations.
  err <- tryCatch(
    initialize_project(
      env = new.env(),
      home = home,
      folders_to_be_sourced = c("x", "y"),
      max_loc_per_file = 1000
    ),
    error = function(e) conditionMessage(e)
  )

  testthat::expect_true(grepl("big_first\\.R", err))
  testthat::expect_true(grepl("big_second\\.R", err))

  unlink(home, recursive = TRUE, force = TRUE)
})

test_that("max_loc_per_file allows a file of exactly the limit", {
  home <- file.path(tempdir(), "org_loc_boundary")
  unlink(home, recursive = TRUE, force = TRUE)
  dir.create(file.path(home, "R"), recursive = TRUE, showWarnings = FALSE)
  writeLines(rep("x <- 1", 1000), file.path(home, "R", "exact.R"))

  target <- new.env()
  initialize_project(
    env = target,
    home = home,
    folders_to_be_sourced = "R",
    max_loc_per_file = 1000
  )
  testthat::expect_equal(target$x, 1)

  unlink(home, recursive = TRUE, force = TRUE)
})

test_that("max_loc_per_file rejects a limit that is not one whole count", {
  home <- file.path(tempdir(), "org_loc_bad_limit")
  unlink(home, recursive = TRUE, force = TRUE)
  dir.create(file.path(home, "R"), recursive = TRUE, showWarnings = FALSE)
  writeLines(rep("x <- 1", 5), file.path(home, "R", "small.R"))

  for (bad in list(NA, NaN, -1, -Inf, 10.5, c(10, 20), "1000")) {
    testthat::expect_error(
      initialize_project(
        env = new.env(),
        home = home,
        folders_to_be_sourced = "R",
        max_loc_per_file = bad
      ),
      "one whole number"
    )
  }

  unlink(home, recursive = TRUE, force = TRUE)
})

test_that("max_loc_per_file checks absolute source folders too", {
  home <- file.path(tempdir(), "org_loc_abs")
  folder <- file.path(tempdir(), "org_loc_abs_code")
  unlink(c(home, folder), recursive = TRUE, force = TRUE)
  dir.create(home, recursive = TRUE, showWarnings = FALSE)
  dir.create(folder, recursive = TRUE, showWarnings = FALSE)
  writeLines(rep("x <- 1", 1001), file.path(folder, "big.R"))

  testthat::expect_error(
    initialize_project(
      env = new.env(),
      home = home,
      folders_to_be_sourced = folder,
      source_folders_absolute = TRUE,
      max_loc_per_file = 1000
    ),
    "big\\.R"
  )

  unlink(c(home, folder), recursive = TRUE, force = TRUE)
})

test_that("max_loc_per_file defaults to checking nothing", {
  home <- file.path(tempdir(), "org_loc_project_inf")
  unlink(home, recursive = TRUE, force = TRUE)
  dir.create(file.path(home, "R"), recursive = TRUE, showWarnings = FALSE)
  writeLines(rep("x <- 1", 5000), file.path(home, "R", "big.R"))

  proj <- initialize_project(
    env = new.env(),
    home = home,
    folders_to_be_sourced = "R"
  )

  testthat::expect_equal(proj$env$x, 1)

  unlink(home, recursive = TRUE, force = TRUE)
})

test_that("Sources multiple code folders that dont exist", {
  unlink(tempdir(), recursive = TRUE, force = TRUE)
  dir.create(tempdir())
  testthat::expect_warning(
    initialize_project(
      env = .GlobalEnv,
      home = tempdir(),
      raw = tempdir(),
      folders_to_be_sourced = c("x2", "y2")
    ),
    "*Creating it now."
  )
})
