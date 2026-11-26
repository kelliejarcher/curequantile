
<!-- README.md is generated from README.Rmd. Please edit that file -->

# curequantile

<!-- badges: start -->

<!-- badges: end -->

The curequantile package can be used to fit quantile regression model
for censored time-to-event data with a cure fraction.

## Installation

You can install the development version of curequantile by issuing:

``` r
install.packages("curequantile")
```

## Example

After loading the relevant R packages,

``` r
library(curequantile)
library(survival)
library(maxLik)
#> Loading required package: miscTools
#> 
#> Please cite the 'maxLik' package as:
#> Henningsen, Arne and Toomet, Ott (2011). maxLik: A package for maximum likelihood estimation in R. Computational Statistics 26(3), 443-458. DOI 10.1007/s00180-010-0217-1.
#> 
#> If you have questions, suggestions, or comments regarding the 'maxLik' package, please use its GitHub page and the issues there:
#> https://github.com/arne-henningsen/maxLik
```

a cure quantile regression model can be fit using the `curequantile`
function.

``` r
data("breast_data")
fit_breast <- curequantile(Surv(log(Time), Delta) ~ Age + Size,
  data = breast_data, subset = 1:200)
```

The `coef()` function extracts the parameter estimates at a specific
quantile `tau`.

``` r
coefficients <- coef(fit_breast, tau = 0.25)
names(coefficients)
#> [1] "gamma_est" "eta_est"   "beta_est"
coefficients$gamma_est
#> (Intercept)         Age        Size 
#> -4.41474759  0.03760906  0.03203235
```

Here, `gamma_est` contains the incidence parameter estimates, while
`beta_est` contains the latency parameter estimates at the specified
quantile, `tau`. Finally, `eta_est` gives the conditional probabilities
of being susceptible, and therefore has a length equal to the number of
rows in the input data frame. Alternatively, `print()` prints the
coefficients at the user-specified quantile `tau` to the console.

The `summary()` function returns the parameter estimates, bootstrap
standard error estimates, Z-test, p-value, and bootstrap confidence
interval for incidence covariates and the latency covariates at the
indicated quantile, `tau`.

The `plot()` function produces a plot of the quantile estimate and
corresponding confidence interval for each covariate over the range of
the user-specified quantiles `tau`.

Other functions designed to handle the resulting model object include:
`dim()`, `formula()`, `logLik()`, `nobs()`, and `predict()`.

## Acknowledgements

We acknowledge Dr. Wei Sun for providing the original R implementation
of the Censored Sliced Inverse Regression procedure, which has been
adapted and modified for use in this package.

## References

Wu, T., Sun, W., Yuan, S., Chen, C.-H., and Li, K.-C. (2008). A method
for analyzing censored survival phenotype with gene expression data. BMC
Bioinformatics, 9, 417. <https://doi.org/10.1186/1471-2105-9-417>
