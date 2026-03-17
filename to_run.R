#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
#                                                                           #
#  Please read README for setting simulation & data generating parameters   #
#                                                                           #
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#

rm(list = ls()) #clean environment
# Load dependent packages and functions
source(file.path("common functionality", "load_packages.R"))
source(file.path("common functionality", "load_functions.R"))

#======= Set global simulation settings =======#
# If you wish to modify the following, go to: setting/global_setting.R
source(file.path("settings", "global_setting.R"))
#---------------------------------------------------
# main                  # cancer stage has no effect on the toxicity outcome
# A1                    # original coefficients extracted from the data
# A2                    # enhance 'T-stage -> dose' & 'T-stage -> dysphagia'
# A3                    # enhance 'T-stage -> dysphagia'
#
# scenario 1            # cancer stage has no effect on the toxicity outcome
# scenario 2            # original coefficients extracted from the data
# scenario 3.1 to 3.2   # enhance 'T-stage -> dose' & 'T-stage -> dysphagia'
# scenario 4.1 to 4.1   # enhance 'T-stage -> dysphagia'
#----------------------------------------------------

#================ Run scripts =================#
for(setting in setting_list){
  for (scenario in scenario_list){
    source(file.path("settings", "scenario_parameters.R"))
    source(file.path("settings", "data_generating_coefficients.R"))
    source(file.path("simulation scripts", "simulation_step1.R"))
    source(file.path("simulation scripts", "simulation_step2.R"))
  }
  # Produce combined tables
  source(file.path("simulation scripts", "combine_results.R"))
  # Produce treatment effect plots
  source(file.path("simulation scripts", "plot_treatment_effect.R"))
}
