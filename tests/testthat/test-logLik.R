test_that("logLik works", {
  library(survival)
  library(maxLik)
  data("breast_data")
  fit_breast <- curequantile(Surv(log(Time), Delta) ~ Age + Size,
                             data = breast_data, subset = 1:200)
  est <- logLik(fit_breast)
  expect_equal(round(est, 2), -53.15, ignore_attr = TRUE)
  expect_length(length(est), 1)
  cox <- coxph(Surv(log(Time), Delta) ~ Age + Size,
               data = breast_data, subset = 1:200)
  expect_error(logLik.curequantile(cox))
})
