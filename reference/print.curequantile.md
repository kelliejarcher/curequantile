# Print a fitted cure quantile regression object

This function prints the estimated coefficients from a fitted cure
quantile regression model fit using `curequantile`. This function
returns the estimates invisible to the user.

## Usage

``` r
# S3 method for class 'curequantile'
print(x, tau = 0.5, ...)
```

## Arguments

- x:

  an object of class `curequantile`.

- tau:

  quantile at which latency coefficients should be estimated.

- ...:

  other arguments.

## Value

invisibly returns a matrix with rows corresponding to the incidence
(gamma) and latency (beta) parameter estimates at the user-specified
quantile tau.

## Examples

``` r
library(survival)
fit_breast <- curequantile(Surv(log(Time), Delta) ~ Age + Size,
  data = breast_data, subset = 1:200)
print(fit_breast, tau = 0.25)
#>       (Intercept)         Age        Size
#> gamma   -4.414748 0.037609062  0.03203235
#> beta     3.555456 0.006326203 -0.01503508
```
