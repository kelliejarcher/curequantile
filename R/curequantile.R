#' Fit quantile regression model for censored time-to-event data with a cure
#' fraction
#'
#' @param formula a model formula.
#' @param data data.frame.
#' @param subset optional subset.
#' @param na.action na.omit is supported.
#' @param n.slice1 Number of slices for event observations in double slicing.
#' @param n.slice0 Number of slices for censored observations in double slicing.
#' @param n.slice Number of time slices in Censor-SIR.
#' @param sir_h Bandwidth parameter used in Censor-SIR.
#' @param sir_c Lower bound for the conditional survival estimate in Censor-SIR.
#'
#' @returns A list with the following components:
#' \item{call}{full call to \code{curequantile} function.}
#' \item{formula}{model formula.}
#' \item{terms}{terms in call to \code{curequantile} function.}
#' \item{model}{\code{model.matrix} extracted from data corresponding to terms.}
#' \item{na.action}{how to handle missing data.}
#' \item{subset}{subset if specified}
#' \item{data}{original data.frame passed to \code{curequantile}.}
#' \item{hn}{the cross-validated bandwidth(s).}
#' \item{P_T_inf}{probability that subject is cured (P(T=infty|x_j) or
#' S_T(t|x) at t >= Y_(n), the largest observed event time.)}
#' \item{F_C_YiZj}{estimated cumulative distribution function.}
#' \item{S_T0}{estimated conditional survival function for the latency
#' component of the model.}
#' \item{f_T0}{estimated density function for the latency component.}
#' \item{data_edr}{data after effective dimension reduction.}
#' @importFrom survival Surv
#' @importFrom stats model.frame model.response model.matrix
#' @export
#'
#' @examples
#' library(survival)
#' library(maxLik)
#' data("breast_data")
#' fit_breast <- curequantile(Surv(log(Time), Delta) ~ Age + Size,
#'   data = breast_data, subset = 1:200)
#' coef_est <- coef(fit_breast, tau = 0.25)
#' coef_est$beta_est
curequantile <- function(formula, data, subset = NULL, na.action = "na.omit",
                         n.slice1 = 5, n.slice0 = 5, n.slice = 10, sir_h = 0.2,
                         sir_c = 0.05) {
  cl <- match.call() # Capture full function call for print/summary methods
  mf <- match.call(expand.dots = FALSE)
  m <- match(c("formula", "data", "subset", "na.action"), names(mf),
             0L)
  if (m[1] == 0)
    stop("Error: A \"formula\" argument is required")
  mf <- mf[c(1L, m)]
  mf[[1L]] <- quote(stats::model.frame) #as.name("model.frame")
  if (missing(data)) {
    mf[["data"]] <- environment(formula)
  }
  mf <- eval(mf, parent.frame())
  mt <- attr(mf, "terms")
  omitted <- attr(mf, "na.action")
  # Keep the original data rows corresponding to the model frame
  data_index <- match(rownames(mf), rownames(data))
  data <- data[data_index, , drop = FALSE]
  mx <- model.frame(formula, data)
  Y <- model.response(mf)
  if (!inherits(Y, "Surv")) {
    stop("The left-hand side of the formula must be a Surv() object.")
  }
  # Sort the data
  if (is.matrix(Y) || inherits(Y, "Surv")) {
    ord <- order(Y[, 1])  # Sort by time variable
  } else {
    ord <- order(Y)
  }
  data <- data[ord, , drop = FALSE]  # order by Y
  mf  <- mf[ord, , drop = FALSE]
  Y <- model.response(mf)
  time <- Y[,1]
  event <- Y[,2]
  x <- model.matrix(mt, mf)
  if (!"(Intercept)" %in% colnames(x)) {
    stop("The model formula must include an intercept.")
  }
  # Remove the intercept for SIR
  x_sir <- x[, colnames(x) != "(Intercept)", drop = FALSE]
  # SIR dimension reduction
  sir_result <- sir_fun(time, event, x_sir,
                        n.slice1 = n.slice1, n.slice0 = n.slice0,
                        n.slice = n.slice, h = sir_h, c = sir_c)
  n <- length(time)

  new_x <- sir_result$new_x
  q_est <- sir_result$q_est
  # data after effective dimension redution
  data_edr <- data.frame(Y = time, delta = event, x = new_x)
  hn <- bandwidth(time = time, event = event, new_x = new_x)  # bandwidth of X.1,...,X.q
  wght <- nw_weight(data_edr[,-(1:2), drop = FALSE], hn)
  #wght <- nw_weight(data_edr[,-(1:2)], hn)  # the NWwight=B.nk(x), dim is j*k, j=1,...n (persons), k=1,...,n
  P_T_inf <- P.T(data_edr, wght)  # P(T=infinit|x.j), j=1,...,n
  F_C_YiZj <- F.C(data_edr, wght)  # F.C([t,inifint|x) at t=Y.i x=x.j
  S_T0 <- F.T0(data_edr, wght, P_T_inf, F_C_YiZj)$S.T0  # F.T0([t,infinit)|x)=S.T0(t|x) at t=Y.i, x=x.i, i=1,...,n
  f_T0 <- F.T0(data_edr, wght, P_T_inf, F_C_YiZj)$f.T0  # f.T0(t|x) = F.T0(dt|x) = S.T0(Y.(i-1)|x.i) - S.T0(Y.i|x.i), at dt=Y.i and x=x.i
  # Standard R fit object structure
  object <- list(
    call       = cl,
    formula    = formula,
    n.slice1   = n.slice1,
    n.slice0   = n.slice0,
    n.slice    = n.slice,
    sir_h      = sir_h,
    sir_c      = sir_c,
    terms      = mt,
    model      = mf,
    na.action  = omitted,
    subset     = subset,
    data       = data,
    hn         = hn,
    P_T_inf    = P_T_inf,
    F_C_YiZj   = F_C_YiZj,
    S_T0       = S_T0,
    f_T0       = f_T0,
    data_edr   = data_edr
  )
  class(object) <- "curequantile"
  return(object)
}
