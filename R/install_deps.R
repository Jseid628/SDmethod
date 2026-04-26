#' Install required Python dependencies
#' @export
install_python_deps <- function(envname = "SDmethod_env", python=NULL) {
  reticulate::virtualenv_create(envname, python = python)
  reticulate::py_install(
    packages = c("cvxpy", "numpy", "torch"),
    envname = envname,
  )
}

# Claude also helped me here.
