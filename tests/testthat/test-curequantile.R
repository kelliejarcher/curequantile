test_that("curequantile works", {
  library(survival)
  library(maxLik)
  data("breast_data")
  fit_breast <- curequantile(Surv(log(Time), Delta) ~ Age + Size,
                             data = breast_data, subset = 1:200)
  returned <- c("call", "formula", "n.slice1", "n.slice0", "n.slice", "sir_h",
                "sir_c", "terms", "model", "na.action", "subset", "data", "hn",
                "P_T_inf", "F_C_YiZj", "S_T0", "f_T0", "data_edr")
  expect_equal(names(fit_breast), returned)
  expect_length(fit_breast$P_T_inf, dim(fit_breast$data)[1])
  expect_length(fit_breast$F_C_YiZj, dim(fit_breast$data)[1]^2)
  expect_length(fit_breast$S_T0, dim(fit_breast$data)[1])
  expect_length(fit_breast$f_T0, dim(fit_breast$data)[1])
  expect_length(fit_breast$n.slice1, 1)
  expect_length(fit_breast$n.slice0, 1)
  expect_length(fit_breast$n.slice, 1)
  expect_s3_class(fit_breast, "curequantile")
  expect_error(curequantile(log(Time) ~ Age + Size, data = breast_data))
  expect_error(curequantile(log(Time), data = breast_data)
  )

})
