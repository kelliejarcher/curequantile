# Number of observations in `curequantile` object

Number of observations in fitted `curequantile` object.

## Usage

``` r
# S3 method for class 'curequantile'
nobs(object, ...)
```

## Arguments

- object:

  An object of class `curequantile`.

- ...:

  other arguments.

## Value

number of subjects in the dataset.

## Examples

``` r
library(survival)
library(maxLik)
data("breast_data")
fit_breast <- curequantile(Surv(log(Time), Delta) ~ Age + Size,
  data = breast_data, subset = 1:200)
nobs(fit_breast)
#> [1] 200
```
