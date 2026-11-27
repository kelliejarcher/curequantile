# Coefficient estimates from a fitted `curequantile` object

Coefficient estimates from a fitted `curequantile` object

## Usage

``` r
# S3 method for class 'curequantile'
coef(object, tau = 0.5, large = 10000, ...)
```

## Arguments

- object:

  an object of class `curequantile`.

- tau:

  quantile at which latency coefficients should be estimated.

- large:

  a large positive constant at which to set censored times.

- ...:

  other optional parameters.

## Value

A list with the following components:

- gamma_est:

  parameter estimates for incidence.

- eta_est:

  estimated conditional probability that the subject is susceptible.

- beta_est:

  parameter estimates for latency at specified quantile tau.

## Examples

``` r
library(survival)
fit_breast <- curequantile(Surv(log(Time), Delta) ~ Age + Size,
    data = breast_data, subset = 1:200)
coef_est <- coef(fit_breast, tau = 0.50)
coef_est$gamma_est
#> (Intercept)         Age        Size 
#> -4.41474767  0.03760906  0.03203235 
coef_est$beta_est
#> (Intercept)         Age        Size 
#>  4.19057671  0.00955579 -0.02360217 
```
