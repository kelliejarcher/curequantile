test_that("dim works", {
  library(survival)
  library(maxLik)
  data("breast_data")
  fit_breast <- curequantile(Surv(log(Time), Delta) ~ Age + Size,
                             data = breast_data, subset = 1:200)
  dimensions <- dim(fit_breast)
  expect_equal(dimensions[1], 200, ignore_attr = TRUE)
  expect_equal(dimensions[2], 3, ignore_attr = TRUE)
  expect_equal(dimensions[3], 3, ignore_attr = TRUE)
  cox <- coxph(Surv(log(Time), Delta) ~ Age + Size,
               data = breast_data, subset = 1:200)
  expect_error(dim.curequantile(cox))
})
