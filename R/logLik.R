#' Log-likelihood for a fitted \code{curequantile} object.
#'
#' @description This function returns the log-likelihood after fitting a
#' cure quantile regression model using \code{curequantile}.
#' @param object an object of class \code{curequantile}.
#' @param ... other optional parameters.
#'
#' @importFrom stats plogis
#' @returns An object of class \code{"logLik"} representing the incidence
#' pseudo-log-likelihood of the fitted model.
#' @keywords methods
#' @method logLik curequantile
#' @export
#'
#' @examples
#' library(survival)
#' fit_breast <- curequantile(Surv(log(Time), Delta) ~ Age + Size,
#'     data = breast_data, subset = 1:200)
#' logLik(fit_breast)
logLik.curequantile <- function(object, ...) {
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
  coef <- coef(object)
  gamma <- matrix(coef$gamma_est, ncol = 1)
  w_gamma <- as.numeric(as.matrix(x_matrix) %*% gamma)
  # pi_hat <- exp(w_gamma)/(1 + exp(w_gamma))
  pi_hat <- plogis(w_gamma)
  # incidence <- sum(delta*log(pi_hat) + delta*log(f_T0))
  # latency <- sum((1 - delta)*log(1 - pi_hat + pi_hat * S_T0))
  incidence <- sum(log(pi_hat[delta == 1]))
  latency <- sum(log(1 - pi_hat[delta == 0] + pi_hat[delta == 0] * S_T0[delta == 0]))
  val <- incidence + latency
  attr(val, "nall") <- nrow(x_matrix)
  attr(val, "nobs") <- nrow(x_matrix)
  attr(val, "df") <- length(coef$gamma_est)
  class(val) <- "logLik"
  return(val)
}
