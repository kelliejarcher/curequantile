test_that("nobs works", {
  library(survival)
  library(maxLik)
  data("breast_data")
  fit_breast <- curequantile(Surv(log(Time), Delta) ~ Age + Size,
                             data = breast_data, subset = 1:200)
  nobservations <- nobs(fit_breast)
  expect_length(length(nobservations), 1)
  expect_equal(nobservations, 200, ignore_attr = TRUE)
  cox <- coxph(Surv(log(Time), Delta) ~ Age + Size,
               data = breast_data, subset = 1:200)
  expect_error(nobs.curequantile(cox))
})

