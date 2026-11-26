#' Number of observations in \code{curequantile} object
#'
#' @description Number of observations in fitted \code{curequantile} object.
#' @param object An object of class \code{curequantile}.
#' @param ... other arguments.
#' @return number of subjects in the dataset.
#' @importFrom stats nobs
#' @export
#' @keywords methods
#' @method nobs curequantile
#' @examples
#' library(survival)
#' library(maxLik)
#' data("breast_data")
#' fit_breast <- curequantile(Surv(log(Time), Delta) ~ Age + Size,
#'   data = breast_data, subset = 1:200)
#' nobs(fit_breast)
nobs.curequantile <- function(object, ...) {
  if (!(inherits(object, "curequantile"))) {
    stop("Error: class of object must be curequantile")
  }
  if (is.null(object$data)) {
    d1 <- NULL
  }
  else d1 <- nrow(object$data)
  d1
}
