#' Remove seasonal components
#'
#' Groups observations by a seasonal index and returns the mean for each
#' group together with the observations after removing those means.
#'
#' @param y Numeric observation vector.
#' @param t_mmdd Seasonal index vector. It must have the same length as `y`.
#'
#' @return A named list with:
#' \itemize{
#'   \item `mu`: seasonal means, ordered by the sorted unique index values.
#'   \item `anomaly`: values with the corresponding seasonal mean removed.
#' }
#'
#' @examples
#' RemoveSeasonal(c(10, 12, 20, 22), c(101, 101, 102, 102))
#'
#' @export
RemoveSeasonal <- function(y, t_mmdd) {
  if (!is.numeric(y)) {
    stop("`y` must be numeric.", call. = FALSE)
  }
  if (length(y) != length(t_mmdd)) {
    stop("`y` and `t_mmdd` must have the same length.", call. = FALSE)
  }
  if (length(y) == 0) {
    stop("`y` must contain at least one observation.", call. = FALSE)
  }
  if (anyNA(t_mmdd)) {
    stop("`t_mmdd` must not contain missing values.", call. = FALSE)
  }

  inds <- sort(unique(t_mmdd))
  mu <- numeric(length(inds))
  anomaly <- numeric(length(y))

  for (i in seq_along(inds)) {
    ind <- which(t_mmdd == inds[i])
    mu[i] <- mean(y[ind], na.rm = TRUE)
    anomaly[ind] <- y[ind] - mu[i]
  }

  list(mu = mu, anomaly = anomaly)
}

#' Fit multiple-breakpoint piecewise regression
#'
#' Fits a piecewise regression with a common slope and separate intercept
#' terms for adjacent segments.
#'
#' @param Y Numeric response vector.
#' @param X Numeric predictor vector. It must have the same length as `Y`.
#' @param Ips Integer-like breakpoint endpoints. The final endpoint must equal
#'   the length of `Y`.
#' @param ... Additional arguments passed to `lm_solve()`.
#'
#' @return A named list containing `coef`, `fitted`, `resi`, and `SSE`.
#'
#' @examples
#' y <- c(1, 2, 4, 5, 7, 8)
#' LS_MultiBreaks(y, seq_along(y), c(3, 6))
#'
#' @export
LS_MultiBreaks <- function(Y, X, Ips, ...) {
  if (!is.numeric(Y) || !is.numeric(X)) {
    stop("`Y` and `X` must be numeric.", call. = FALSE)
  }
  if (length(Y) == 0 || length(Y) != length(X)) {
    stop("`Y` and `X` must be non-empty and have the same length.", call. = FALSE)
  }
  if (length(Ips) < 1 || anyNA(Ips) ||
      any(Ips != as.integer(Ips)) ||
      tail(Ips, 1) != length(Y) ||
      any(diff(Ips) <= 0)) {
    stop("`Ips` must contain increasing integer endpoints ending at length(Y).", call. = FALSE)
  }

  n_breaks <- length(Ips) - 1
  design <- cbind(1, X - mean(X))

  for (i in seq_len(n_breaks)) {
    segment <- numeric(length(Y))
    segment[(Ips[i] + 1):Ips[i + 1]] <- 1
    design <- cbind(design, segment)
  }

  lm_solve(design, Y, ...)
}

#' Fit single-breakpoint piecewise regression
#'
#' Fits a piecewise regression with a common slope and a separate intercept
#' on each side of a breakpoint.
#'
#' @param Y Numeric response vector.
#' @param X Numeric predictor vector. It must have the same length as `Y`.
#' @param Ic Position of the change point. `[1, Ic]` is the first segment and
#'   `[Ic + 1, end]` is the second segment. `NA` fits a model without a
#'   breakpoint.
#' @param ... Additional arguments passed to `lm_solve()`. `only.SSE = TRUE`
#'   returns only the residual sum of squares.
#'
#' @return A named list containing `coef`, `fitted`, `resi`, and `SSE`, or only
#'   `SSE` when `only.SSE = TRUE`.
#'
#' @examples
#' y <- c(1, 2, 3, 7, 8, 9)
#' LS_OneBreak(y, seq_along(y), Ic = 3)
#'
#' @export
LS_OneBreak <- function(Y, X, Ic, ...) {
  if (!is.numeric(Y) || !is.numeric(X)) {
    stop("`Y` and `X` must be numeric.", call. = FALSE)
  }
  if (length(Y) == 0 || length(Y) != length(X)) {
    stop("`Y` and `X` must be non-empty and have the same length.", call. = FALSE)
  }

  n <- length(Y)
  design <- cbind(1, X)

  if (!is.na(Ic)) {
    if (length(Ic) != 1 || Ic != as.integer(Ic) || Ic < 1 || Ic >= n) {
      stop("`Ic` must be NA or an integer between 1 and length(Y) - 1.", call. = FALSE)
    }
    design <- cbind(design, c(rep(0, Ic), rep(1, n - Ic)))
  }

  lm_solve(design, Y, ...)
}

#' Solve least-squares fit with a precomputed design matrix
#'
#' @param design Numeric design matrix.
#' @param response Numeric response vector.
#' @param only.SSE Logical; if `TRUE`, return only the residual sum of squares.
#' @param ... Reserved for compatibility.
#'
#' @return A named list containing coefficients, fitted values, residuals, and
#'   sum of squared errors. When `only.SSE = TRUE`, only `SSE` is returned.
#'
#' @keywords internal
lm_solve <- function(design, response, only.SSE = FALSE, ...) {
  l <- .lm.fit(design, as.matrix(response))
  fitted <- design %*% l$coefficients
  SSE <- sum(l$residuals^2)

  if (!only.SSE) {
    list(
      coef = l$coefficients,
      fitted = as.vector(fitted),
      resi = l$residuals,
      SSE = SSE
    )
  } else {
    list(SSE = SSE)
  }
}
