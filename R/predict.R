#' Predictions from a fitted cure quantile regression model
#'
#' @param object an object of class \code{curequantile}.
#' @param newdata an optional new data.frame for which to get predictions.
#' @param tau quantile at which model should be estimated.
#' @param back_transform logical (default TRUE). Indicates whether latency
#' predictions should be exponentiated if log transformed time was modeled.
#' @param ... other optional parameters.
#'
#' @returns A list with the following components:
#' \item{p_cured}{estimated probability that the subject is cured.}
#' \item{latency}{linear predictor for latency at user-specified tau.}
#' \item{tau}{user-specified quantile, tau.}
#' @keywords methods
#' @method predict curequantile
#' @importFrom stats as.formula delete.response terms
#' @export
#'
#' @examples
#' library(survival)
#' fit_breast <- curequantile(Surv(log(Time), Delta) ~ Age + Size,
#'     data = breast_data, subset = 1:200)
#' phat <- predict(fit_breast, tau = 0.50)
#' hist(phat$p_cured, xlab = "Cure Probability",
#'   main = paste("Estimate at ", phat$tau))
predict.curequantile <- function(object, newdata = NULL, tau = 0.50,
                                 back_transform = TRUE, ...) {
  if (!(inherits(object, "curequantile"))) {
    stop("Error: class of object must be curequantile")
  }
  mf <- object$model
  mt <- object$terms
  call_info <- object$call
  if (is.null(mf) || is.null(mt)) {
    stop("Object does not contain stored 'model' or 'terms'.")
  }
  main_formula <- as.formula(object$call$formula)
  main_terms   <- delete.response(terms(main_formula))
  if (!is.null(newdata)) {
    x_matrix <- model.matrix(main_terms, data = newdata)
  } else {
    x_matrix <- model.matrix(mt, mf)
  }
  coef_est <- coef(object, tau = tau)
  incidence <- x_matrix %*% coef_est$gamma_est
  pi_hat <- exp(incidence)/(1 + exp(incidence))
  latency <- x_matrix %*% coef_est$beta_est
  if (back_transform) {
    latency <- exp(latency)
  }
  return(list(p_cured = 1 - pi_hat, latency = latency, tau = tau))
}
