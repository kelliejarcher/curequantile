test_that("coef works", {
  library(survival)
  library(maxLik)
  data("breast_data")
  fit_breast <- curequantile(Surv(log(Time), Delta) ~ Age + Size,
                             data = breast_data, subset = 1:200)
  coefficients <- coef(fit_breast, tau = 0.25)
  expect_equal(round(coefficients$beta_est[2], 4), 0.0063, ignore_attr = TRUE)
  expect_equal(round(coefficients$gamma_est[2], 4), 0.0376, ignore_attr = TRUE)
  expect_equal(round(coefficients$eta_est[1], 4), 0.3291, ignore_attr = TRUE)
  expect_length(coefficients$gamma_est, 3)
  expect_length(coefficients$beta_est, 3)
  expect_length(coefficients$eta_est, 200)
  cox <- coxph(Surv(log(Time), Delta) ~ Age + Size,
               data = breast_data, subset = 1:200)
  expect_error(coef.curequantile(cox))
})
