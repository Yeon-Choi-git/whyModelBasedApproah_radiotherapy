
# multiplier for the coefficients from T-stage to the exposure (dose)
multiplier_tstage_to_dose <- case_when(
  scenario %in% c("1", "2", "4.1", "4.2") ~ 1,
  scenario %in% c("3.1") ~ 1.5,
  scenario %in% c("3.2") ~ 3
)

# multiplier for the coefficients from T-stage to the outcome (dysphagia at 6m)

multiplier_tstage_to_outcome <- case_when(
  scenario %in% c("1", "2") ~ 1,
  scenario %in% c("3.1", "4.1") ~ 1.5,
  scenario %in% c("3.2", "4.2") ~ 3
)

tstage_to_dosediff <- ifelse(setting %in% c("main", "A1"), FALSE, TRUE)
tstage_to_dose <- ifelse(setting == "A3" | scenario == "1", FALSE, TRUE)

message(paste("Scenario parameters for", setting, scenario, "is loaded."))
