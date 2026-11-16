test_that("the sourcing order is the same under LC_ALL=C and en_US.UTF-8", {
  testthat::skip_on_cran()
  testthat::skip_on_os("windows")

  expected <- c(
    # folder R2
    "_z.R",
    "9.R",
    "A.R",
    "b.R",
    # folder R
    "_under.R",
    "1digit.R",
    "alpha.R",
    "beta.R",
    "Beta.R",
    "Zed.r",
    # folder R3: "_" sorts before "."
    "get_data_2020.R",
    "get_data.R",
    "load_nordic.R",
    "load.R"
  )

  for (loc in c("C", "en_US.UTF-8")) {
    home <- tempfile("org_order_")
    log <- file.path(home, "order.log")
    write_order_files(
      file.path(home, "R2"),
      c("b.R", "A.R", "_z.R", "9.R"),
      log
    )
    write_order_files(
      file.path(home, "R"),
      c("_under.R", "1digit.R", "alpha.R", "Beta.R", "beta.R", "Zed.r"),
      log
    )
    write_order_files(
      file.path(home, "R3"),
      c("get_data.R", "get_data_2020.R", "load.R", "load_nordic.R"),
      log
    )

    got <- run_org_child(
      c(
        sprintf(
          "invisible(suppressMessages(org::initialize_project(home = %s, folders_to_be_sourced = c('R2', 'R', 'R3'))))",
          deparse(home)
        ),
        sprintf(
          "cat(readLines(%s), file = out, sep = '\\n', append = TRUE)",
          deparse(log)
        )
      ),
      loc
    )
    if (!identical(sub("^LOCALE=", "", got[1]), loc)) {
      unlink(home, recursive = TRUE)
      testthat::skip(paste("the locale", loc, "is not available"))
    }
    testthat::expect_identical(got[-1], expected, info = loc)
    unlink(home, recursive = TRUE)
  }
})

test_that("sort_for_sourcing() puts punctuation, then digits, then letters", {
  x <- c(
    "b.R",
    "a.R",
    "a_b.R",
    "a-b.R",
    "a b.R",
    "a1.R",
    "A.r",
    "a.r",
    "aB.R",
    "Ab.R"
  )
  testthat::expect_identical(
    sort_for_sourcing(file.path("dir", x)),
    file.path(
      "dir",
      c(
        "a b.R",
        "a_b.R",
        "a-b.R",
        "a.r",
        "a.R",
        "A.r",
        "a1.R",
        "aB.R",
        "Ab.R",
        "b.R"
      )
    )
  )
  testthat::expect_identical(sort_for_sourcing(character(0)), character(0))
})
