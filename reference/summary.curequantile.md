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
  tau = 0.25,
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

## Examples

``` r
library(survival)
fit_breast <- curequantile(Surv(log(Time), Delta) ~ Size,
    data = breast_data, subset = 1:200)
summary <- summary(fit_breast, tau = 0.50, b = 10)
#> Incidence estimates from fitted model: 
#> 
#>               gamma_est   gamma_se      Z       Pvalue        2.5%      97.5%
#> (Intercept) -2.11415818 0.53224388 -3.972 7.127172e-05 -3.56907728 -1.9349425
#> Size         0.02958308 0.03798412  0.779 4.359797e-01  0.02382188  0.1344256
#> 
#> Latency estimates at tau =  0.5 
#> 
#>                beta_est    beta_se      Z       Pvalue       2.5 %      97.5 %
#> (Intercept)  4.32016437 0.45172277  9.564 1.132914e-21  3.97280336 4.996466975
#> Size        -0.01765176 0.01610613 -1.096 2.730788e-01 -0.04272943 0.003114929
```
