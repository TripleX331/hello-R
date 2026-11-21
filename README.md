
# R package template

<!-- badges: start -->
[![R-CMD-check](https://github.com/rpkgs/rpkg.template/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/rpkgs/rpkg.template/actions/workflows/R-CMD-check.yaml)
[![codecov](https://codecov.io/gh/rpkgs/rpkg.template/branch/master/graph/badge.svg)](https://app.codecov.io/gh/rpkgs/rpkg.template)
<!-- [![CRAN](http://www.r-pkg.org/badges/version/rpkg.template)](https://cran.r-project.org/package=rpkg.template) -->
<!-- [![total](http://cranlogs.r-pkg.org/badges/grand-total/rpkg.template)](https://www.rpackages.io/package/rpkg.template) -->
<!-- [![monthly](http://cranlogs.r-pkg.org/badges/rpkg.template)](https://www.rpackages.io/package/rpkg.template) -->
<!-- badges: end -->

`rpkg.template` provides lightweight utilities for seasonal decomposition and
piecewise regression:

- `RemoveSeasonal()` computes seasonal means and removes them from observations.
- `LS_OneBreak()` and `LS_MultiBreaks()` fit piecewise least-squares models.

## Installation

You can install the development version of `rpkg.template` like so:

``` r
remotes::install_github("rpkgs/rpkg.template")
```

## Example

Remove a monthly seasonal cycle:

``` r
library(rpkg.template)

result <- RemoveSeasonal(
  y = c(10, 12, 20, 22),
  t_mmdd = c(101, 101, 102, 102)
)
result$mu
#> [1] 11 21
result$anomaly
#> [1] -1 1 -1 1
```
