# Summarize a fitted `curequantile` object

This function returns the parameter estimates, bootstrap standard
errors, Z-test statistics, p-values, and bootstrap confidence intervals
for both the incidence covariates and the latency covariates at the
specified quantile, `tau`.

## Usage

``` r
# S3 method for class 'curequantile'
summary(
  object,
  b = 200,
  probs = c(0.025, 0.975),
  tau = 0.5,
  large = 10000,
  seed = NULL,
  ...
)
```

## Arguments

- object:

  an object of class `curequantile`.

- b:

  number of bootstrap replicated for standard error estimation. Default
  is `b = 200`.

- probs:

  percentiles for a bootstrap confidence interval. Default is
  c(0.025,0.975).

- tau:

  quantile at which latency parameters are to be estimated.

- large:

  a large positive constant at which to set censored times.

- seed:

  optional random seed to promote reproducibility.

- ...:

  optional arguments.

## Value

A list with the following components:

- gamma_hat:

  a matrix that includes the parameter estimates, bootstrap standard
  error estimates, Z-test, p-value, and bootstrap confidence interval
  for incidence covariates.

- beta_hat:

  a matrix that includes the parameter estimates, bootstrap standard
  error estimates, Z-test, p-value, and bootstrap confidence interval
  for latency covariates at the user-supplied quantile tau.

- tau:

  user-specified quantile.

- b:

  number of bootstrap resamples used in estimating standard error.

## Examples

``` r
library(survival)
fit_breast <- curequantile(Surv(log(Time), Delta) ~ Size,
    data = breast_data, subset = 1:200)
summary <- summary(fit_breast, tau = 0.50, b = 10)
#> Warning: number of items to replace is not a multiple of replacement length
```
