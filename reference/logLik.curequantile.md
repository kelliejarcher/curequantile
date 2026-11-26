# Log-likelihood for a fitted `curequantile` object.

This function returns the log-likelihood after fitting a cure quantile
regression model using `curequantile`.

## Usage

``` r
# S3 method for class 'curequantile'
logLik(object, ...)
```

## Arguments

- object:

  an object of class `curequantile`.

- ...:

  other optional parameters.

## Value

An object of class `"logLik"` representing the incidence
pseudo-log-likelihood of the fitted model.

## Examples

``` r
library(survival)
fit_breast <- curequantile(Surv(log(Time), Delta) ~ Age + Size,
    data = breast_data, subset = 1:200)
logLik(fit_breast)
#> 'log Lik.' -53.14851 (df=3)
```
