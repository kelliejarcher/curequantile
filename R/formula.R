#' Extract model formula for a \code{curequantile} object
#'
#' @description Extract the model formula for \code{curequantile} object
#' @param x an object from class \code{curequantile}.
#' @param ... other arguments.
#'
#' @returns a formula representing the variables in the quantile cure regression
#' model.
#' @keywords methods
#' @method formula curequantile
#' @importFrom stats getCall
#' @export
#'
#' @examples
#' library(survival)
#' data("breast_data")
#' fit_breast <- curequantile(Surv(log(Time), Delta) ~ Age + Size,
#'   data = breast_data, subset = 1:200)
#' formula(fit_breast)
formula.curequantile <- function(x, ...) {
  if (!((inherits(x, "curequantile")))) {
    stop("Error: class of object must be curequantile")
  }
  if (is.null(x$call))
    form <- NULL
  else
    form <- getCall(x)
  form
}
