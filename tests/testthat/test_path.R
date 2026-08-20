context("path")

test_that("path joins scalar components", {
  testthat::expect_equal(org::path("home", "user", "data.csv"), "home/user/data.csv")
  testthat::expect_equal(org::path("home//user", "data.csv"), "home/user/data.csv")
})

test_that("path returns a single component unchanged", {
  testthat::expect_equal(org::path("home/user"), "home/user")
  testthat::expect_equal(org::path(c("a", "b")), c("a", "b"))
})

test_that("path recycles its components, as file.path does", {
  # Before this was fixed, a multi-element component was deparsed into the path
  # itself, so this returned the single string `home/c("a.csv", "b.csv")`.
  testthat::expect_equal(
    org::path("home", c("a.csv", "b.csv")),
    c("home/a.csv", "home/b.csv")
  )
  testthat::expect_equal(
    org::path(c("x", "y"), "f.csv"),
    c("x/f.csv", "y/f.csv")
  )
  testthat::expect_equal(
    org::path(c("x", "y"), c("a", "b")),
    c("x/a", "y/b")
  )
  testthat::expect_equal(
    org::path("home", c("a.csv", "b.csv")),
    unname(file.path("home", c("a.csv", "b.csv")))
  )
})

test_that("path returns nothing when a component has length zero", {
  testthat::expect_equal(org::path("home", character(0)), character(0))
  testthat::expect_equal(org::path("home", NULL), character(0))
  testthat::expect_equal(org::path(), character(0))
})
