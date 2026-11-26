#' Coefficient estimates from a fitted \code{curequantile} object
#'
#' @param object an object of class \code{curequantile}.
#' @param tau quantile at which latency coefficients should be estimated.
#' @param large a large positive constant at which to set censored times.
#' @param ... other optional parameters.
#'
#' @returns A list with the following components:
#' \item{gamma_est}{parameter estimates for incidence.}
#' \item{eta_est}{estimated conditional probability that the subject is
#' susceptible.}
#' \item{beta_est}{parameter estimates for latency at specified quantile tau.}
#' @importFrom stats model.response model.matrix
#' @import parallel
#' @export
#' @keywords methods
#' @method coef curequantile
#' @examples
#' library(survival)
#' fit_breast <- curequantile(Surv(log(Time), Delta) ~ Age + Size,
#'     data = breast_data, subset = 1:200)
#' coef_est <- coef(fit_breast, tau = 0.50)
#' coef_est$gamma_est
#' coef_est$beta_est
coef.curequantile <- function(object, tau = 0.25, large = 10000, ...) {
  if (!(inherits(object, "curequantile"))) {
    stop("Error: class of object must be curequantile")
  }
  mf <- object$model
  mt <- object$terms
  if (is.null(mf) || is.null(mt)) {
    stop("Object does not contain stored 'model' or 'terms'.")
  }
  Y <- model.response(mf)
  time <- Y[,1]
  delta <- Y[,2]
  x_matrix <- model.matrix(mt, mf)
  S_T0 <- object$S_T0
  f_T0 <- object$f_T0
  gamma_est <- Get_gamma(time, delta, x_matrix, S_T0, f_T0)
  eta_est <- Get_eta(time, delta, x_matrix, gamma_est, S_T0)
  beta_est <- Get_beta(time, delta, x_matrix, S_T0, eta_est, tau, large)
  results <- list(gamma_est = gamma_est, eta_est = eta_est, beta_est = beta_est)
  results
}
