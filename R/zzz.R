#' @noRd
.onLoad <- function(libname, pkgname) {
  reticulate::py_require(c("cvxpy", "numpy", "torch"))
}

# Note: Claude helped me figure this part out
