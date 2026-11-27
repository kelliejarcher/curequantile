#' Summarize a fitted \code{curequantile} object
#'
#' @description This function returns the parameter estimates, bootstrap
#' standard  errors, Z-test statistics, p-values, and bootstrap confidence
#' intervals for both the incidence covariates and the latency covariates at the
#' specified quantile, \code{tau}.
#'
#' @param object an object of class \code{curequantile}.
#' @param b number of bootstrap replicated for standard error estimation.
#' Default is \code{b = 200}.
#' @param probs percentiles for a bootstrap confidence interval. Default is
#' c(0.025,0.975).
#' @param tau quantile at which latency parameters are to be estimated.
#' @param large a large positive constant at which to set censored times.
#' @param seed optional random seed to promote reproducibility.
#' @param ... optional arguments.
#'
#' @returns A list with the following components:
#' \item{gamma_hat}{a matrix that includes the parameter estimates, bootstrap
#' standard error estimates, Z-test, p-value, and bootstrap confidence interval
#' for incidence covariates.}
#' \item{beta_hat}{a matrix that includes the parameter estimates, bootstrap
#' standard error estimates, Z-test, p-value, and bootstrap confidence interval
#' for latency covariates at the user-supplied quantile tau.}
#' \item{tau}{user-specified quantile.}
#' \item{b}{number of bootstrap resamples used in estimating standard error.}
#' @keywords methods
#' @method summary curequantile
#' @importFrom stats pnorm
#' @export
#'
#' @examples
#' library(survival)
#' fit_breast <- curequantile(Surv(log(Time), Delta) ~ Size,
#'     data = breast_data, subset = 1:200)
#' summary <- summary(fit_breast, tau = 0.50, b = 10)
summary.curequantile <- function(object, b = 200, probs = c(0.025, 0.975),
                                 tau = 0.50, large = 10000, seed = NULL, ...) {
  if (length(tau) > 1) {
    stop("Error: summary() function accepts one value of tau")
  }
  resamples <- bootstrap_plot(object, B = b, probs = probs, seed = seed,
                            tau = tau, large = large)
  gamma_z <- resamples$gamma_est/resamples$gamma_std_err
  gamma_p <- pnorm(abs(gamma_z), lower.tail = FALSE)*2
  gamma_hat <- cbind(resamples$gamma_est, resamples$gamma_std_err, gamma_z,
                      gamma_p, t(resamples$gamma_percentile))
  ci_labels <- paste0(probs * 100, "%")
  colnames(gamma_hat)[1:4] <- c("gamma_est", "gamma_se", "Z", "Pvalue", ci_labels)
  beta_z <- resamples$beta_est/resamples$beta_std_err
  beta_p <- pnorm(abs(beta_z), lower.tail = FALSE)*2
  beta_percentile <- matrix(0, nrow = length(beta_p), ncol = 2)
  for (i in 1:length(beta_p)) {
    beta_percentile[i,] <- t(resamples$beta_percentile[,,i])
  }
  beta_hat <- cbind(as.numeric(resamples$beta_est),
                    as.numeric(resamples$beta_std_err),
                    as.numeric(beta_z),
                    as.numeric(beta_p),
                    beta_percentile)
  colnames(beta_hat) <- c("beta_est", "beta_se", "Z", "Pvalue", ci_labels)
  rownames(beta_hat) <- rownames(gamma_hat)
  return_object <- list(gamma_hat = gamma_hat, beta_hat = beta_hat, tau = tau,
                        b = b)
  class(return_object) <- "summary.curequantile"
  return_object
}



#' Print a summary of a fitted \code{curequantile} object
#'
#' @param x an object of class \code{summary.curequantile}.
#' @param digits minimal number of significant digits.
#' @param ... additional arguments passed to \code{\link{printCoefmat}}.
#' @export
#' @method print summary.curequantile
print.summary.curequantile <- function(x,
                                       digits = max(3L, getOption("digits") - 3L),
                                       ...) {
  cat("Incidence estimates from fitted model:\n\n")
  stats::printCoefmat(x$gamma_hat, digits = digits, P.values = TRUE,
                      has.Pvalue = TRUE, ...)
  cat("\nLatency estimates at tau =", x$tau, "\n\n")
  stats::printCoefmat(x$beta_hat, digits = digits, P.values = TRUE,
                      has.Pvalue = TRUE, ...)
  invisible(x)
}
