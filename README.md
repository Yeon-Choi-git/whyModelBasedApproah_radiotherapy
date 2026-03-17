### "Missing confounding information in counterfactual prediction models: a simulation study on model-based treatment effect evaluation in radiotherapy techniques"

This repository contains the R scripts used to generate the simulation results presented in the manuscript:

Choi J, et al. "Missing confounding information in counterfactual prediction models: a simulation study on model-based treatment effect evaluation in radiotherapy techniques." (Link to be added)

The scripts reproduce analyses and figures presented in the manuscript.

## Note

Please note that the numerical values of the outputs obtained from running the scripts may not exactly match the numerical values presented in the manuscript. This is because the original script used for the manuscript contains a step extracting data generating coefficients from individual-level patient data. The script is slightly modified to skip using the patient data and instead read hard-coded coefficients used in the original scripts.

## Repo structure

1.  `common fucntionality` contains loading of dependent R packages and functions.
2.  `setting` contains scenario-specific parameters and data generating coefficients.
    1.  `scenario_parameters.R` specify setting/scenario-specific parameters used for data generation. (see manuscript section: *Simulation scenarios* and *Modified simulation settings*)
    2.  `data_generating_coefficients.R` contains all coefficients used for data generation. Coefficients are hard-coded using the values extracted from patient data. The script depends on the setting/ scenario-specific parameters specified in the above script.
3.  `simulation scripts` contains scripts for running simulations.
    1.  `generate_data.R` generates simulated data sets based on scripts 2.1 and 2.2.
    2.  `simulation_step1.R` runs step 1; NTCP model development (see manuscript section: *Step 1. Model development*)
    3.  `simulation_step2.R` runs step2; model-based selection and evaluation (see manuscript section: *Model-based patient selection and model-based clinical evaluation)*
    4.  `combine_results.R` summarize the results across all settings and scenarios and summarize into tables. Results are saved under `results`.
    5.  `plot_treatment_effect.R` generates box plots for treatment effect estimates summarized over all iteration per setting. Results are saved under `results`.

## How to run the script

1.  Set parameters in the scripts under `setting`. For the parameters to replicate the manuscript, see the section below.
2.  Go to `to_run.R` and source the script.

## Parameters settings

#### Global setting

-   `n_step1`: number of observations for step 1

-   `n_step2`: number of observations for step 2

-   `cutoff_per`: cutoff values for predicted ∆NTCP for selection proton-receiving patients

-   `nsim`: number of iterations for step 2

-   `seep_step1` and `seed_step2`:

-   `setting_list`: names of simulation settings to run (main, A1, A2, A3)

-   `scenario_list`: scenario numbers to run (1, 2, 3.1, 3.2, 4.1, 4.2)

Setting used in the manuscript

```         
n_step1 <- 50000
n_step2 <- 5000
cutoff_per <- c(0, 0.1, 0.2)
nsim <- 1000
seed_step1 <- "" # see "Notes" in this README.
seed_step2 <- "" # see "Notes" in this README.
setting_list <- c("main", "A1", "A2", "A3")
scenario_list <- c("1", "2", "3.1", "3.2", "4.1", "4.2")
```

#### Scenario paramteres

-   multiplier_tstage_to_does: multiplier for regression coefficients from T-stage to doses to organs at risks (exposure)

-   multiplier_tstage_to_outcome: multiplier for regression coefficients from T-stage to dysphagia at 6 months (outcome)

-   tstate_to_dosediff: whether dose reduction from photon to proton therapy is depended to T-stage.

-   tstage_to_dose: whether doses organs at risks is dependent to T-stage.

Settings used in the manuscript

|   | Main | A1 | A2 | A3 |
|---------------|---------------|---------------|---------------|---------------|
| Is **T-stage** **confounding** doses to OARs and NTCP (dose-outcome relationship)? `tstate_to_dose` | `TRUE` | `TRUE` | `TRUE` | `FALSE` |
| Is **T-stage** an **effect modifier** of the treatment effect? `tstage_to_dosediff` | `FALSE` | `FALSE` | `TRUE` | `TRUE` |
| Which model was used for the model-based selection? (specified in `simulation scripts/simulation_step2.R` line 70-76) | Current model | Extended model | Current model | Current model |
