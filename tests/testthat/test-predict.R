test_that("predict works", {
  cox <- coxph(Surv(log(Time), Delta) ~ Age + Size,
               data = breast_data, subset = 1:200)
  expect_error(predict.curequantile(cox))
  library(survival)
  library(maxLik)
  data("breast_data")
  fit_breast <- curequantile(Surv(log(Time), Delta) ~ Age + Size,
                             data = breast_data, subset = 1:200)
  test <- breast_data[201:462,]
  training_p <- predict(fit_breast)
  expect_equal(round(training_p$p_cured[1], 3), 0.671, ignore_attr = TRUE)
  expect_equal(round(training_p$latency[1], 3), 79.002, ignore_attr = TRUE)
  testing_p <- predict(fit_breast, newdata = test)
  expect_equal(round(testing_p$p_cured[1], 3), 0.812, ignore_attr = TRUE)
  expect_equal(round(testing_p$latency[1], 1), 101.8, ignore_attr = TRUE)
})
