#' Dimension method for a \code{curequantile} object
#'
#' @description Dimension method for a \code{curequantile} object.
#' @param x An object of class \code{curequantile}.
#'
#' @return \item{nobs}{number of subjects in the dataset.}
#' @return \item{p_incidence}{number of variables in the incidence portion of
#'    the model.}
#' @return \item{p_latency}{number of variables in the latency portion of the
#'    model.}
#' @export
#' @keywords methods
#' @method dim curequantile
#' @examples
#' library(survival)
#' fit_breast <- curequantile(Surv(log(Time), Delta) ~ Age + Size,
#'     data = breast_data, subset = 1:200)
#' dim(fit_breast)
dim.curequantile <- function(x) {
  if (!((inherits(x, "curequantile")))) {
    stop("Error: class of object must be curequantile")
  }
  d1name <- "nobs"
  d2name <- "p_incidence"
  d3name <- "p_latency"
  if (is.null(x$data)) {
    d1 <- d1name <- NULL
  }
  else d1 <- nrow(x$data)
  coef <- coef(x)
  if (is.null(coef$gamma_est)) {
    d2 <- d2name <- NULL
  } else {
    d2 <- length(coef$gamma_est)
  }
  if (is.null(coef$beta_est)) {
    d3 <- d3name <- NULL
  } else {
    d3 <- length(coef$beta_est)
  }
  dd <- c(d1, d2, d3)
  names(dd) <- c(d1name, d2name, d3name)
  dd
}
