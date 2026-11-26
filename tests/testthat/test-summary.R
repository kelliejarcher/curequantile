test_that("summary works", {
  library(survival)
  library(maxLik)
  data("breast_data")
  fit_breast <- curequantile(Surv(log(Time), Delta) ~ Age + Size,
                             data = breast_data, subset = 1:200)
  set.seed(2)
  summary <- summary(fit_breast, tau = 0.25, b = 5)
  expect_equal(round(summary$gamma_hat["Age","gamma_se"], 4), 0.056, ignore_attr = TRUE)
  expect_equal(round(summary$beta_hat["Age","beta_se"], 4), 0.0153, ignore_attr = TRUE)
  summary$beta_hat %>% expect_type("double")
  summary$gamma_hat %>% expect_type("double")
  expect_error(summary(fit_breast, tau = c(0.25, .5, .75), b = 5))
})
