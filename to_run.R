rm(list = ls()) #clean environment

# Load dependent packages and functions
source(file.path("common functionality", "load_packages.R"))
source(file.path("common functionality", "load_functions.R"))
# create a folder to save results
results_dir <- file.path("results")
if(!dir.exists(results_dir)) dir.create(results_dir)

#======= Set global simulation settings =======#
#--- Number of observations for each step.
n_step1 <- 50000 # Step 1: model development
n_step2 <- 5000  # Step 2: model validation

# Which cutoff for predicted ∆NTCP to use for selection proton patients?
# Use values between 0 to 1
cutoff_per <- c(0, 0.1, 0.2) 

# How many simulation iterations to run for Step 2?
nsim <- 500

# Set seeds
seed_step1 <- NULL #971123 
seed_step2 <- NULL #570313 

#===== Which settings & scenarios to run? =====#
# Please read READ.ME for specific parameter settings of 
# each simulation setting & scenario.
#---------------------------------------------------
# Main                  # cancer stage has no effect on the toxicity outcome
# A1                    # original coefficients extracted from the data
# A2                    # enhance 'T-stage -> dose' & 'T-stage -> dysphagia'
# A3                    # enhance 'T-stage -> dysphagia'
#
# scenario 1            # cancer stage has no effect on the toxicity outcome
# scenario 2            # original coefficients extracted from the data
# scenario 3.1 to 3.2   # enhance 'T-stage -> dose' & 'T-stage -> dysphagia'
# scenario 4.1 to 4.1   # enhance 'T-stage -> dysphagia'
#----------------------------------------------------
# possible settings to add: "main", "A1", "A2", "A3"
setting_list <- c("main", "A1", "A2", "A3") 
# possible scenario to add: "1", "2", "3.1", "3.2", "4.1", "4.2"
scenario_list <- c("1", "2", "3.1", "3.2", "4.1", "4.2")

#================ Run scripts =================#
for(setting in setting_list){
  for (scenario in scenario_list){
    source(file.path("settings", "scenario_parameters.R"))
    source(file.path("settings", "data_generating_coefficients.R"))
    source(file.path("simulation scripts", "simulation_step1.R"))
    source(file.path("simulation scripts", "simulation_step2.R"))
  }
  source(file.path("simulation scripts", "combine_results.R"))
}
# Produce treatment effect plots
source(file.path("simulation scripts", "plot_treatment_effect.R"))


