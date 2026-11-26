# Subset of TARGET-AML data

Dataset includes 1,405 pediatric patients diagnosed with acute myeloid
leukemia and enrolled in the TARGET-AML study.

## Usage

``` r
target_aml
```

## Format

A data.frame with 1,405 rows and 15 columns:

- time_years:

  event-free survival time in years.

- event_status:

  censoring indicator: 0 = no event, 1 = event.

- age:

  age at diagnosis in years.

- race:

  race of the patient.

- ethnicity:

  ethnicity of the patient.

- sex:

  biological sex of the patient.

- risk_group:

  European LeukemiaNet risk group at diagnosis.

- cns_disease:

  indication of whether the patient had CNS involvement.

- t_8_21:

  indication of whether the patient had a t(8;21) cytogenetic
  abnormality.

- inv_16:

  indication of whether the patient had an inv(16) cytogenetic
  abnormality.

- KLRF1:

  normalized expression for KLRF1.

- IL1R2:

  normalized expression for IL1R2.

- EIF4EBP1:

  normalized expression for EIF4EBP1.

- CDKN2A:

  normalized expression for CDKN2A.

## Source

\<https://www.cancer.gov/ccg/research/genome-sequencing/target/studied-cancers/acute-myeloid-leukemia#targets-aml-project\>
