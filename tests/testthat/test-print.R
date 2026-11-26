test_that("print works", {
  library(survival)
  library(maxLik)
  data("breast_data")
  fit_breast <- curequantile(Surv(log(Time), Delta) ~ Age + Size,
                             data = breast_data, subset = 1:200)
  output <- print(fit_breast, tau = 0.25)
  expect_equal(round(output["beta", "Age"], 4), 0.0063)
  expect_length(output["beta",], 3)
  expect_length(output[, "Age"], 2)
  expect_equal(round(output["gamma", "Age"], 4), 0.0376)
  fit_breast_2 <- curequantile(Surv(log(Time), Delta) ~ Age + Size + ER,
                             data = breast_data, subset = 1:200)
  output_2 <- print(fit_breast_2, tau = 0.25)
  expect_equal(round(output_2["beta", "Age"], 4), 0.0057)
  fit_breast_3 <- curequantile(Surv(log(Time), Delta) ~ Age,
                             data = breast_data, subset = 1:200)
  output_3 <- print(fit_breast_3, tau = 0.25)
  expect_equal(round(output_3["beta", "Age"], 4), 0.0077)
})
