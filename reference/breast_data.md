# SEER breast cancer data from Han, Van Keilegom, Wang (2026) JASA

Dataset includes 462 women diagnosed with localized or regional breast
cancer between 2004 and 2017 from Surveillance Epidemiology and End
Results database residing in county code 175 (Union of Iowa, Morgan of
Kentucky, and Laurens of Georgia) .

## Usage

``` r
breast_data
```

## Format

A data.frame with 462 rows and 7 columns:

- Time:

  overall survival time (months since diagnosis).

- Delta:

  censoring indicator: 0 = no event, 1 = event.

- Age:

  age at diagnosis in years.

- Size:

  tumor size (mm).

- Surgery:

  indicator of whether subject had surgery (1) or not (0).

- ER:

  estrogen receptor status (0 = ER-; 1 = ER+).

- PR:

  progesteron receptor status (0 = PR-; 1 = PR+).

## References

Han, B., Van Keilegom, I., Wang, X. (2026). Quantile regression for
censored data with a cure fraction. *Journal of the American Statistical
Association*, in press.
