# Each test works in its own root under tempdir(), with the working directory
# set to `home`. A value that wrongly becomes a folder through `...` is a
# relative path, so it lands in `home`, where the test can see it.
new_root <- function() {
  root <- tempfile("org_subfolder_")
  dir.create(file.path(root, "home"), recursive = TRUE)
  return(normalizePath(root, winslash = "/"))
}

init <- function(...) {
  return(suppressMessages(initialize_project(
    env = new.env(),
    folders_to_be_sourced = NULL,
    ...
  )))
}

date_pattern <- "[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]"

test_that("results_subfolder names results_today and creates no dated folder", {
  root <- new_root()
  home <- file.path(root, "home")
  results <- file.path(root, "results")
  old_wd <- setwd(home)
  on.exit(
    {
      setwd(old_wd)
      unlink(root, recursive = TRUE)
    },
    add = TRUE
  )

  proj <- init(home = home, results = results, results_subfolder = "v01")

  want <- paste0(results, "/v01/")
  testthat::expect_identical(proj$results_today, want)
  testthat::expect_identical(org::project$results_today, want)
  testthat::expect_true(dir.exists(want))
  testthat::expect_identical(
    list.files(results, all.files = TRUE, no.. = TRUE),
    "v01"
  )
  testthat::expect_false(any(grepl(
    date_pattern,
    list.dirs(root, full.names = FALSE)
  )))
  testthat::expect_identical(
    sort(ls(proj, all.names = TRUE)),
    c("computer_id", "env", "home", "results", "results_today")
  )
  testthat::expect_identical(
    list.files(home, all.files = TRUE, no.. = TRUE),
    character(0)
  )
})

test_that("results_subfolder accepts a nested relative path", {
  root <- new_root()
  home <- file.path(root, "home")
  results <- file.path(root, "results")
  old_wd <- setwd(home)
  on.exit(
    {
      setwd(old_wd)
      unlink(root, recursive = TRUE)
    },
    add = TRUE
  )

  proj <- init(
    home = home,
    results = results,
    results_subfolder = "null/sim_0003"
  )

  want <- paste0(results, "/null/sim_0003/")
  testthat::expect_identical(proj$results_today, want)
  testthat::expect_identical(org::project$results_today, want)
  testthat::expect_true(dir.exists(want))
  testthat::expect_identical(list.files(results), "null")
  testthat::expect_identical(list.files(file.path(results, "null")), "sim_0003")

  # A name has one spelling: a trailing slash is refused.
  testthat::expect_error(
    init(home = home, results = results, results_subfolder = "a/b/"),
    "results_subfolder"
  )
  testthat::expect_false(dir.exists(file.path(results, "a")))
})

test_that("results_subfolder rejects a value that is not one non-empty string", {
  root <- new_root()
  home <- file.path(root, "home")
  results <- file.path(root, "results")
  old_wd <- setwd(home)
  on.exit(
    {
      setwd(old_wd)
      unlink(root, recursive = TRUE)
    },
    add = TRUE
  )

  bad_values <- list(
    character(0),
    c("a", "b"),
    NA_character_,
    NA,
    "",
    1,
    TRUE,
    list("a")
  )
  for (bad in bad_values) {
    testthat::expect_error(
      init(home = home, results = results, results_subfolder = bad),
      "`results_subfolder` must be NULL or one non-empty character string"
    )
  }
  # The check runs before any folder is created.
  testthat::expect_false(dir.exists(results))
  testthat::expect_identical(
    list.files(home, all.files = TRUE, no.. = TRUE),
    character(0)
  )
})

test_that("results_subfolder rejects an absolute path", {
  root <- new_root()
  home <- file.path(root, "home")
  results <- file.path(root, "results")
  old_wd <- setwd(home)
  on.exit(
    {
      setwd(old_wd)
      unlink(root, recursive = TRUE)
    },
    add = TRUE
  )

  for (bad in c(
    "/abs",
    file.path(root, "abs"),
    "\\\\server\\share",
    "C:/abs",
    "c:abs"
  )) {
    testthat::expect_error(
      init(home = home, results = results, results_subfolder = bad),
      "`results_subfolder` must be a relative path inside `results`"
    )
  }
  testthat::expect_false(dir.exists(results))
  testthat::expect_false(dir.exists(file.path(root, "abs")))
  testthat::expect_identical(
    list.files(home, all.files = TRUE, no.. = TRUE),
    character(0)
  )
})

test_that("results_subfolder rejects a path that contains ..", {
  root <- new_root()
  home <- file.path(root, "home")
  results <- file.path(root, "results")
  old_wd <- setwd(home)
  on.exit(
    {
      setwd(old_wd)
      unlink(root, recursive = TRUE)
    },
    add = TRUE
  )

  for (bad in c("..", "../up", "a/../b", "a\\..\\b", "v1..2")) {
    testthat::expect_error(
      init(home = home, results = results, results_subfolder = bad),
      "`results_subfolder` must not contain `..`"
    )
  }
  testthat::expect_false(dir.exists(results))
  testthat::expect_false(dir.exists(file.path(root, "up")))
  testthat::expect_identical(
    list.files(home, all.files = TRUE, no.. = TRUE),
    character(0)
  )
})

test_that("results_subfolder without results stops", {
  root <- new_root()
  home <- file.path(root, "home")
  old_wd <- setwd(home)
  on.exit(
    {
      setwd(old_wd)
      unlink(root, recursive = TRUE)
    },
    add = TRUE
  )

  testthat::expect_error(
    init(home = home, results_subfolder = "v01"),
    "`results_subfolder` needs `results`"
  )
  testthat::expect_identical(
    list.files(home, all.files = TRUE, no.. = TRUE),
    character(0)
  )
  testthat::expect_identical(list.files(root), "home")
})

test_that("without results_subfolder, the folders and the returned object are unchanged", {
  root <- new_root()
  home <- file.path(root, "home")
  results <- file.path(root, "results")
  old_wd <- setwd(home)
  on.exit(
    {
      setwd(old_wd)
      unlink(root, recursive = TRUE)
    },
    add = TRUE
  )

  # One empty dated folder, which the clean-up deletes. One dated folder with
  # content, one dated file and one undated empty folder, which it keeps.
  dir.create(file.path(results, "2020-01-01"), recursive = TRUE)
  dir.create(file.path(results, "2020-01-02"))
  writeLines("x", file.path(results, "2020-01-02", "keep.txt"))
  writeLines("x", file.path(results, "2020-01-03.txt"))
  dir.create(file.path(results, "notes"))

  proj <- init(home = home, results = results, raw = file.path(root, "raw"))
  today <- format.Date(Sys.time(), "%Y-%m-%d")

  testthat::expect_setequal(
    list.dirs(root, full.names = FALSE),
    c(
      "",
      "home",
      "raw",
      "results",
      "results/2020-01-02",
      "results/notes",
      paste0("results/", today)
    )
  )
  testthat::expect_setequal(
    list.files(results),
    c("2020-01-02", "2020-01-03.txt", "notes", today)
  )
  testthat::expect_identical(
    sort(ls(proj, all.names = TRUE)),
    c("computer_id", "env", "home", "raw", "results", "results_today")
  )
  testthat::expect_identical(proj$home, paste0(home, "/"))
  testthat::expect_identical(proj$results, paste0(results, "/"))
  testthat::expect_identical(
    proj$results_today,
    paste0(results, "/", today, "/")
  )
  testthat::expect_identical(proj$raw, paste0(root, "/raw/"))
  testthat::expect_identical(proj$computer_id, 1L)
  for (nm in c(
    "computer_id",
    "env",
    "home",
    "raw",
    "results",
    "results_today"
  )) {
    testthat::expect_identical(org::project[[nm]], proj[[nm]], label = nm)
  }
})

test_that("a named folder that holds a date survives the clean-up", {
  root <- new_root()
  home <- file.path(root, "home")
  results <- file.path(root, "results")
  old_wd <- setwd(home)
  on.exit(
    {
      setwd(old_wd)
      unlink(root, recursive = TRUE)
    },
    add = TRUE
  )

  proj <- init(home = home, results = results, results_subfolder = "2020-01-01")
  testthat::expect_identical(
    proj$results_today,
    paste0(results, "/2020-01-01/")
  )
  testthat::expect_true(dir.exists(proj$results_today))
  testthat::expect_true(dir.exists(org::project$results_today))
})

test_that("results_subfolder is matched by name and never becomes a project folder", {
  root <- new_root()
  home <- file.path(root, "home")
  results <- file.path(root, "results")
  old_wd <- setwd(home)
  on.exit(
    {
      setwd(old_wd)
      unlink(root, recursive = TRUE)
    },
    add = TRUE
  )

  value <- "org_probe_value"
  proj <- init(home = home, results = results, results_subfolder = value)

  testthat::expect_false(dir.exists(file.path(home, value)))
  testthat::expect_false(dir.exists(file.path(root, value)))
  testthat::expect_false("results_subfolder" %in% ls(proj, all.names = TRUE))
  testthat::expect_false(
    "results_subfolder" %in% ls(org::project, all.names = TRUE)
  )

  # An unknown named argument still becomes a folder, as before.
  proj <- init(
    home = home,
    results = results,
    results_subfolder = value,
    extra_folder = file.path(root, "extra")
  )
  testthat::expect_identical(proj$extra_folder, paste0(root, "/extra/"))
  testthat::expect_identical(org::project$extra_folder, paste0(root, "/extra/"))
  testthat::expect_true(dir.exists(file.path(root, "extra")))
  testthat::expect_false("results_subfolder" %in% ls(proj, all.names = TRUE))
})

test_that("results_subfolder accepts only plain folder names joined by /", {
  root <- new_root()
  home <- file.path(root, "home")
  results <- file.path(root, "results")
  on.exit(unlink(root, recursive = TRUE), add = TRUE)

  for (bad in c("a|b", "a//b", "run\\2020-01-01", "a b", "a/ /b")) {
    testthat::expect_error(
      initialize_project(
        home = home,
        results = results,
        results_subfolder = bad
      ),
      "results_subfolder"
    )
  }
  testthat::expect_false(dir.exists(results) && length(list.files(results)) > 0)

  dir.create(file.path(home, "R"))
  proj <- initialize_project(
    home = home,
    results = results,
    results_subfolder = "null-1/sim_0003.x"
  )
  testthat::expect_true(dir.exists(proj$results_today))
})
