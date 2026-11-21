test_that("RemoveSeasonal returns sorted means and anomalies", {
  result <- RemoveSeasonal(c(10, 12, 20, 22), c(102, 101, 102, 101))

  expect_equal(result$mu, c(17, 15))
  expect_equal(result$anomaly, c(-5, -5, 5, 5))
})

test_that("RemoveSeasonal handles NA observations", {
  result <- RemoveSeasonal(c(10, NA, 20, 22), c(101, 101, 102, 102))

  expect_equal(result$mu, c(10, 21))
  expect_true(is.na(result$anomaly[2]))
})

test_that("RemoveSeasonal validates inputs", {
  expect_error(RemoveSeasonal("10", 101), "`y` must be numeric")
  expect_error(RemoveSeasonal(1:3, 1:2), "same length")
  expect_error(RemoveSeasonal(1:3, c(1, NA, 3)), "must not contain")
})

test_that("LS_OneBreak fits a known two-segment model", {
  x <- 1:6
  y <- c(1, 2, 3, 7, 8, 9)
  fit <- LS_OneBreak(y, x, Ic = 3)

  expect_length(fit$coef, 3)
  expect_equal(fit$fitted, y, tolerance = 1e-10)
  expect_lt(fit$SSE, 1e-20)
})

test_that("LS_OneBreak can omit a breakpoint", {
  fit <- LS_OneBreak(1:5, 1:5, Ic = NA, only.SSE = TRUE)

  expect_named(fit, "SSE")
  expect_equal(fit$SSE, 0)
})

test_that("LS_OneBreak validates change points", {
  expect_error(LS_OneBreak(1:3, 1:3, 0), "between 1")
  expect_error(LS_OneBreak(1:3, 1:3, 3), "between 1")
})

test_that("LS_MultiBreaks fits segments with a common slope", {
  x <- 1:6
  y <- c(1, 2, 4, 5, 7, 8)
  fit <- LS_MultiBreaks(y, x, c(3, 6))

  expect_length(fit$coef, 3)
  expect_length(fit$fitted, 6)
  expect_equal(sum(fit$resi), 0, tolerance = 1e-10)
  expect_gte(fit$SSE, 0)
})

test_that("LS_MultiBreaks validates breakpoint endpoints", {
  expect_error(LS_MultiBreaks(1:4, 1:4, c(2, 3)), "ending")
  expect_error(LS_MultiBreaks(1:4, 1:4, c(3, 2, 4)), "increasing")
})
