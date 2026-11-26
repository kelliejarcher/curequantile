test_that("plot works", {
  library(survival)
  library(maxLik)
  data("breast_data")
  fit_breast <- curequantile(Surv(log(Time), Delta) ~ Age + Size,
                             data = breast_data, subset = 1:200)
  expect_visible(plot(fit_breast, tau = seq(.25, .75, by = 0.25), b = 5))
  cox <- coxph(Surv(log(Time), Delta) ~ Age + Size,
               data = breast_data, subset = 1:200)
  expect_error(plot.curequantile(cox))
})
