# Extract model formula for a `curequantile` object

Extract the model formula for `curequantile` object

## Usage

``` r
# S3 method for class 'curequantile'
formula(x, ...)
```

## Arguments

- x:

  an object from class `curequantile`.

- ...:

  other arguments.

## Value

a formula representing the variables in the quantile cure regression
model.

## Examples

``` r
library(survival)
data("breast_data")
fit_breast <- curequantile(Surv(log(Time), Delta) ~ Age + Size,
  data = breast_data, subset = 1:200)
formula(fit_breast)
#> curequantile(formula = Surv(log(Time), Delta) ~ Age + Size, data = breast_data, 
#>     subset = 1:200)
```
