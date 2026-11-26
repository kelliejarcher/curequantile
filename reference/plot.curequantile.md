# Plot a fitted `curequantile` object

This function produces a plot of the quantile estimate and corresponding
confidence interval for each covariate over the range of the
user-specified quantiles `tau`.

## Usage

``` r
# S3 method for class 'curequantile'
plot(
  x,
  conf.level = 0.95,
  tau = seq(0.25, 0.75, by = 0.25),
  b = 10,
  seed = 2,
  large = 10000,
  ...
)
```

## Arguments

- x:

  an object of class `curequantile`.

- conf.level:

  confidence level (default is 0.95).

- tau:

  range of quantiles and specific values at which estimates and
  confidence intervals are to be constructed for each parameter.

- b:

  number of bootstrap resamples (default `b = 100`).

- seed:

  optional seed to enhance reproducibility.

- large:

  large positive constant at which to set times for those cured.

- ...:

  other arguments.

## Value

this function has no returned value but is called for its side effects.

## Examples

``` r
library(survival)
fit_breast <- curequantile(Surv(log(Time), Delta) ~ Age + Size,
  data = breast_data, subset = 1:200)
plot(fit_breast, tau = seq(0.25, 0.75, by = 0.25), b = 10)
```
