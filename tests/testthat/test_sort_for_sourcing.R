test_that("org::sort_for_sourcing() gives the order initialize_project() sources in", {
  testthat::skip_on_cran()
  testthat::skip_on_os("windows")

  # Under LC_ALL=C, sort() puts the upper case names and 9.R first, and
  # get_data.R before get_data_2020.R. The rule of org gives this order.
  expected <- c(
    "_cfg.R",
    "10.R",
    "9.R",
    "a.R",
    "B.R",
    "clean_data.r",
    "get_data_2020.R",
    "get_data.R",
    "SaveA4.r"
  )
  given <- c(
    "SaveA4.r",
    "get_data.R",
    "get_data_2020.R",
    "clean_data.r",
    "B.R",
    "a.R",
    "9.R",
    "10.R",
    "_cfg.R"
  )

  for (loc in c("C", "en_US.UTF-8")) {
    home <- tempfile("org_export_")
    log <- file.path(home, "order.log")
    write_order_files(file.path(home, "R"), given, log)

    got <- run_org_child(
      c(
        sprintf(
          "invisible(suppressMessages(org::initialize_project(home = %s)))",
          deparse(home)
        ),
        sprintf(
          "cat(readLines(%s), file = out, sep = '\\n', append = TRUE)",
          deparse(log)
        ),
        "cat('EXPORTED\\n', file = out, append = TRUE)",
        sprintf(
          "cat(basename(org::sort_for_sourcing(file.path(%s, 'R', %s))), file = out, sep = '\\n', append = TRUE)",
          deparse(home),
          paste(deparse(given), collapse = "")
        )
      ),
      loc
    )
    if (!identical(sub("^LOCALE=", "", got[1]), loc)) {
      # A machine may lack en_US.UTF-8. The C locale is on every machine,
      # and its run above is the one that differs from sort().
      unlink(home, recursive = TRUE)
      next
    }
    split <- match("EXPORTED", got)
    testthat::expect_false(is.na(split), info = paste(got, collapse = "\n"))
    sourced <- got[2:(split - 1)]
    exported <- got[-seq_len(split)]
    testthat::expect_identical(exported, sourced, info = loc)
    testthat::expect_identical(sourced, expected, info = loc)
    unlink(home, recursive = TRUE)
  }
})

test_that("org::sort_for_sourcing() takes file names as well as paths", {
  testthat::expect_identical(
    org::sort_for_sourcing(c("plot.R", "Get.R", "get.R", "_cfg.R")),
    c("_cfg.R", "get.R", "Get.R", "plot.R")
  )
})
