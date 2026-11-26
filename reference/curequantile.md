# Fit quantile regression model for censored time-to-event data with a cure fraction

Fit quantile regression model for censored time-to-event data with a
cure fraction

## Usage

``` r
curequantile(
  formula,
  data,
  subset = NULL,
  na.action = "na.omit",
  n.slice1 = 5,
  n.slice0 = 5,
  n.slice = 10,
  sir_h = 0.2,
  sir_c = 0.05
)
```

## Arguments

- formula:

  a model formula.

- data:

  data.frame.

- subset:

  optional subset.

- na.action:

  na.omit is supported.

- n.slice1:

  Number of slices for event observations in double slicing.

- n.slice0:

  Number of slices for censored observations in double slicing.

- n.slice:

  Number of time slices in Censor-SIR.

- sir_h:

  Bandwidth parameter used in Censor-SIR.

- sir_c:

  Lower bound for the conditional survival estimate in Censor-SIR.

## Value

A list with the following components:

- call:

  full call to `curequantile` function.

- formula:

  model formula.

- terms:

  terms in call to `curequantile` function.

- model:

  `model.matrix` extracted from data corresponding to terms.

- na.action:

  how to handle missing data.

- subset:

  subset if specified

- data:

  original data.frame passed to `curequantile`.

- hn:

  the cross-validated bandwidth(s).

- P_T_inf:

  probability that subject is cured (P(T=infty\|x_j) or S_T(t\|x) at t
  \>= Y\_(n), the largest observed event time.)

- F_C_YiZj:

  estimated cumulative distribution function.

- S_T0:

  estimated conditional survival function for the latency component of
  the model.

- f_T0:

  estimated density function for the latency component.

- data_edr:

  data after effective dimension reduction.

## References

Han, Bo, Van Keilegom, Ingrid, Wang, Xiaoguang (2026). Quantile
regression for censored data with a cure fraction. Journal of the
American Statistical Association, in press. DOI
10.1080/01621459.2026.2723402.

Henningsen, Arne and Toomet, Ott (2011). maxLik: A package for maximum
likelihood estimation in R. Computational Statistics 26(3), 443-458. DOI
10.1007/s00180-010-0217-1.

Wu, T., Sun, W., Yuan, S., Chen, C.-H., and Li, K.-C. (2008). A method
for analyzing censored survival phenotype with gene expression data. BMC
Bioinformatics, 9, 417. DOI 10.1186/1471-2105-9-417.

## Examples

``` r
library(survival)
library(maxLik)
#> Loading required package: miscTools
#> 
#> Please cite the 'maxLik' package as:
#> Henningsen, Arne and Toomet, Ott (2011). maxLik: A package for maximum likelihood estimation in R. Computational Statistics 26(3), 443-458. DOI 10.1007/s00180-010-0217-1.
#> 
#> If you have questions, suggestions, or comments regarding the 'maxLik' package, please use its GitHub page and the issues there:
#> https://github.com/arne-henningsen/maxLik
data("breast_data")
fit_breast <- curequantile(Surv(log(Time), Delta) ~ Age + Size,
  data = breast_data, subset = 1:200)
coef_est <- coef(fit_breast, tau = 0.25)
coef_est$beta_est
#>  (Intercept)          Age         Size 
#>  3.555455746  0.006326203 -0.015035082 
```
