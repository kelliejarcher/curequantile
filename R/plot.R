#' Plot a fitted \code{curequantile} object
#'
#' @description This function produces a plot of the quantile estimate and
#' corresponding confidence interval for each covariate over the range of the
#' user-specified quantiles \code{tau}.
#'
#' @param x an object of class \code{curequantile}.
#' @param conf.level confidence level (default is 0.95).
#' @param tau range of quantiles and specific values at which estimates and
#' confidence intervals are to be constructed for each parameter.
#' @param b number of bootstrap resamples (default \code{b = 100}).
#' @param seed optional seed to enhance reproducibility.
#' @param large large positive constant at which to set times for those cured.
#' @param ...  other arguments.
#'
#' @returns this function has no returned value but is called for its side
#' effects.
#' @importFrom stats qnorm
#' @import ggplot2
#' @method plot curequantile
#' @export
#' @examples
#' library(survival)
#' fit_breast <- curequantile(Surv(log(Time), Delta) ~ Age + Size,
#'   data = breast_data, subset = 1:200)
#' plot(fit_breast, tau = seq(0.25, 0.75, by = 0.25), b = 10)
plot.curequantile <- function(x, conf.level = 0.95,
                 tau = seq(0.25, 0.75, by = 0.25), b = 10,
                 seed = 2, large = 10000, ...) {
  if (!is.null(seed)) {
    set.seed(seed)
  }
  covariate_names <- names(coef(x)$beta_est)
  n_tau <- length(tau)
  #for (i in 1:length(tau)) {
  #  summary[[i]] <- summary(x, tau = tau[i], b = b, seed = seed, large = large)
  #}
  probs <- c((1-conf.level)/2, 1 - (1-conf.level)/2)
  bootstrap_results <- bootstrap_plot(object = x, B = b, tau = tau,
                                      probs = probs, large = large, seed = seed)

  p1 <- dim(bootstrap_results$beta_est)[2]
  beta_estimate <- bootstrap_results$beta_est
  beta_se <- bootstrap_results$beta_std_err
  lower_ci <- bootstrap_results$beta_est -
    qnorm(1 - (1 - conf.level)/2) * beta_se
  upper_ci = bootstrap_results$beta_est +
    qnorm(1 - (1 - conf.level)/2) * beta_se

  # Reshape matrices into a tidy data frame for passing to ggplot
  df_long <- do.call(rbind, lapply(1:p1, function(i) {
    data.frame(
      tau = tau,
      covariate = covariate_names[i],
      beta_estimate = beta_estimate[, i],
      lower_ci = lower_ci[, i],
      upper_ci = upper_ci[, i]
    )
  }))
  # Plot using ggplot2
  ggplot(df_long, aes(x = tau, y = beta_estimate)) +
    # Zero reference line
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    # Shaded 95% Confidence Interval
    geom_ribbon(aes(ymin = lower_ci, ymax = upper_ci), fill = "skyblue", alpha = 0.4) +
    # Beta estimate line
    geom_line(color = "navy", linewidth = 1) +
    # Create a grid layout with 3 columns
    facet_wrap(~ covariate, ncol = 3,  scales = "free_y") +
    # Formatting & Labels
    labs(
      x = expression(tau),
      y = expression(paste("Coefficient Estimate (", beta, ")"))
    ) +
    theme_minimal() +
    theme(
      strip.text = element_text(face = "bold", size = 11),
      panel.grid.minor = element_blank(),
      axis.title = element_text(size = 11)
    )
}
