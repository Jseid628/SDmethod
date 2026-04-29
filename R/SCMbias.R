#' Calculate the bias in the estimators
#'
#' Calculates the difference between the prediction and the truth.
#' @param Y0 Matrix of control outcomes
#' @param Y1 Vector of target outcomes
#' @param weights The estimated synthetic control weights
#'
#' @export
SCMbias <- function(Y0,Y1,weights) {
  synthY0 <- (Y0%*%weights)
  gap <- Y1-synthY0
  return(gap)
}
