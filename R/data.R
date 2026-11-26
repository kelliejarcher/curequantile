#' SEER breast cancer data from Han, Van Keilegom, Wang (2026) JASA
#'
#' Dataset includes 462 women diagnosed with localized or regional breast cancer
#' between 2004 and 2017 from Surveillance Epidemiology and End Results database
#' residing in county code 175 (Union of Iowa, Morgan of Kentucky, and
#' Laurens of Georgia) .
#'
#' @format A data.frame with 462 rows and 7 columns:
#' \describe{
#' \item{Time}{overall survival time (months since diagnosis).}
#' \item{Delta}{censoring indicator: 0 = no event, 1 = event.}
#' \item{Age}{age at diagnosis in years.}
#' \item{Size}{tumor size (mm).}
#' \item{Surgery}{indicator of whether subject had surgery (1) or not (0).}
#' \item{ER}{estrogen receptor status (0 = ER-; 1 = ER+).}
#' \item{PR}{progesteron receptor status (0 = PR-; 1 = PR+).}
#' }
#' @references Han, B., Van Keilegom, I., Wang, X. (2026). Quantile regression
#' for censored data with a cure fraction. \emph{Journal of the American
#' Statistical Association}, in press.
"breast_data"


#' Subset of TARGET-AML data
#'
#' Dataset includes 1,405 pediatric patients diagnosed with acute myeloid
#' leukemia and enrolled in the TARGET-AML study.
#'
#' @format A data.frame with 1,405 rows and 15 columns:
#' \describe{
#' \item{time_years}{event-free survival time in years.}
#' \item{event_status}{censoring indicator: 0 = no event, 1 = event.}
#' \item{age}{age at diagnosis in years.}
#' \item{race}{race of the patient.}
#' \item{ethnicity}{ethnicity of the patient.}
#' \item{sex}{biological sex of the patient.}
#' \item{risk_group}{European LeukemiaNet risk group at diagnosis.}
#' \item{cns_disease}{indication of whether the patient had CNS involvement.}
#' \item{t_8_21}{indication of whether the patient had a t(8;21) cytogenetic
#' abnormality.}
#' \item{inv_16}{indication of whether the patient had an inv(16) cytogenetic
#' abnormality.}
#' \item{KLRF1}{normalized expression for KLRF1.}
#' \item{IL1R2}{normalized expression for IL1R2.}
#' \item{EIF4EBP1}{normalized expression for EIF4EBP1.}
#' \item{CDKN2A}{normalized expression for CDKN2A.}
#' }
#' @source <https://www.cancer.gov/ccg/research/genome-sequencing/target/studied-cancers/acute-myeloid-leukemia#targets-aml-project>
"target_aml"
