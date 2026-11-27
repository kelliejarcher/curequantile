# Predictions from a fitted cure quantile regression model

Predictions from a fitted cure quantile regression model

## Usage

``` r
# S3 method for class 'curequantile'
predict(object, newdata = NULL, tau = 0.5, back_transform = TRUE, ...)
```

## Arguments

- object:

  an object of class `curequantile`.

- newdata:

  an optional new data.frame for which to get predictions.

- tau:

  quantile at which model should be estimated.

- back_transform:

  logical (default TRUE). Indicates whether latency predictions should
  be exponentiated if log transformed time was modeled.

- ...:

  other optional parameters.

## Value

A list with the following components:

- p_cured:

  estimated probability that the subject is cured.

- latency:

  linear predictor for latency at user-specified tau.

- tau:

  user-specified quantile, tau.

## Examples

``` r
library(survival)
fit_breast <- curequantile(Surv(log(Time), Delta) ~ Age + Size,
    data = breast_data, subset = 1:200)
phat <- predict(fit_breast, tau = 0.50)
hist(phat$p_cured, xlab = "Cure Probability",
  main = paste("Estimate at ", phat$tau))
```
