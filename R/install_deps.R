#' Installs required Python dependencies
#'
#' Creates a virtual environment with the necessary dependencies for the R package to work.
#'
#' @param envname The name of the environment
#' @param python Path to a python version to use, can be left empty
#'
#' @export
install_python_deps <- function(envname = "SDmethod_env", python=NULL) {
  reticulate::virtualenv_create(envname, python = python)
  reticulate::py_install(
    packages = c("cvxpy", "numpy", "torch"),
    envname = envname,
  )
}

# Note: Claude helped me here.
