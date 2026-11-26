# Dimension method for a `curequantile` object

Dimension method for a `curequantile` object.

## Usage

``` r
# S3 method for class 'curequantile'
dim(x)
```

## Arguments

- x:

  An object of class `curequantile`.

## Value

- nobs:

  number of subjects in the dataset.

- p_incidence:

  number of variables in the incidence portion of the model.

- p_latency:

  number of variables in the latency portion of the model.

## Examples

``` r
library(survival)
fit_breast <- curequantile(Surv(log(Time), Delta) ~ Age + Size,
    data = breast_data, subset = 1:200)
dim(fit_breast)
#>        nobs p_incidence   p_latency 
#>         200           3           3 
```
