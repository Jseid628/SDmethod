#' Calculates the RMSE
#' @param Y0 Matrix of control outcomes
#' @param Y1 Vector of target outcomes
#' @param weights The estimated synthetic control weights
#'
#' @export
rmse <- function(Y0,Y1,weights) {
  synthY0 <- (Y0%*%weights)
  gap <- Y1-synthY0
  return(sqrt(mean(gap^2)))
}
