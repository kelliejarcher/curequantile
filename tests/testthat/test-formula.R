test_that("formula works", {
  library(survival)
  library(maxLik)
  data("breast_data")
  fit_breast <- curequantile(Surv(log(Time), Delta) ~ Age + Size,
                             data = breast_data, subset = 1:200)

  form <- formula(fit_breast)
  form %>% expect_type("language")
  cox <- coxph(Surv(log(Time), Delta) ~ Age + Size,
               data = breast_data, subset = 1:200)
  expect_error(formula.curequantile(cox))
})
