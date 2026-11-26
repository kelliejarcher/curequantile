#' Print a fitted cure quantile regression object
#'
#' @description This function prints the estimated coefficients from a
#' fitted cure quantile regression model fit using \code{curequantile}. This
#' function returns the estimates invisible to the user.
#'
#' @param x an object of class \code{curequantile}.
#' @param tau quantile at which latency coefficients should be estimated.
#' @param ... other arguments.
#'
#' @returns invisibly returns a matrix with rows corresponding to the
#' incidence (gamma) and latency (beta) parameter estimates at the
#' user-specified quantile tau.
#' @importFrom stats coef
#' @importFrom survival Surv
#' @export
#' @keywords methods
#' @method print curequantile
#' @examples
#' library(survival)
#' fit_breast <- curequantile(Surv(log(Time), Delta) ~ Age + Size,
#'   data = breast_data, subset = 1:200)
#' print(fit_breast, tau = 0.25)
print.curequantile <- function(x, tau = 0.50, ...) {
  coefficients <- coef(x, tau = tau)
  return <- rbind(coefficients$gamma_est, coefficients$beta_est)
  dimnames(return)[[1]] <- c("gamma", "beta")
  print(return)
  invisible(return)
}
