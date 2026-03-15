set.seed(seed_step1)

source(file.path("simulation scripts", "generate_data.R"))
step1_dat <- generate_data(n_step1)

message("Step 1: Data for model development generated.")

# model without cancer stage
current_formula <- paste("outcome_dysphagia_RT ~ 
                      primary_tumor_location +
                      baseline_dysphagia +
                      RT_oral_cavity +
                      RT_PCM_superior +
                      RT_PCM_medius +
                      RT_PCM_inferior")

# model without baseline dysphagia
extended_formula <- paste(current_formula, "+ t_stage")

#== NTCP model developed based on the PHOTON planning of the simulated data
# current mode1l 
current_mod <- glm(as.formula(current_formula),
                   family = binomial,
                   data = step1_dat)
message("Step 1: NTCP-current model (not including T-stage) fitted.")

# full model (include tumor stage)
extended_mod <- glm(as.formula(extended_formula),
                    family = binomial,
                    data = step1_dat)

message("Step 1: NTCP-extended model (including T-stage) fitted.")
rm(step1_dat)

# 
# # get C-index
# truestat <- step1_dat[, outcome_dysphagia_RT] # true binary outcome
# 
# testres_extended <- predict(full_mod, newdata = step1_dat, type = "response") # predicted ntcp from the full model
# c_stat_full_modeldevelopment <- rcorr.cens(testres_full,truestat)[1]
# 
# testres_current <- predict(current_mod, newdata = sim_dat, type = "response") # predicted ntcp from the current model
# c_stat_current_modeldevelopment <- rcorr.cens(testres_current, truestat)[1]
# 
# testres_reduced <- predict(reduced_mod, newdata = sim_dat, type = "response") # predicted ntcp from the reduced model
# c_stat_reduced_modeldevelopment <- rcorr.cens(testres_reduced, truestat)[1]
# 
# 
# # save model coefficients
# # full model
# intercept_full <- coef(full_mod)[1]
# coef_full_oral_cavity <- coef(full_mod)["RT_oral_cavity"]*10
# coef_full_PCM_superior <- coef(full_mod)["RT_PCM_superior"]*10
# coef_full_PCM_medius <- coef(full_mod)["RT_PCM_medius"]*10
# coef_full_PCM_inferior <- coef(full_mod)["RT_PCM_inferior"]*10
# # current model
# intercept_current <- coef(current_mod)[1]
# coef_current_oral_cavity <- coef(current_mod)["RT_oral_cavity"]*10
# coef_current_PCM_superior <- coef(current_mod)["RT_PCM_superior"]*10
# coef_current_PCM_medius <- coef(current_mod)["RT_PCM_medius"]*10
# coef_current_PCM_inferior <- coef(current_mod)["RT_PCM_inferior"]*10  
# # reduced model
# intercept_reduced <- coef(reduced_mod)[1]
# coef_reduced_oral_cavity <- coef(reduced_mod)["RT_oral_cavity"]*10
# coef_reduced_PCM_superior <- coef(reduced_mod)["RT_PCM_superior"]*10
# coef_reduced_PCM_medius <- coef(reduced_mod)["RT_PCM_medius"]*10
# coef_reduced_PCM_inferior <- coef(reduced_mod)["RT_PCM_inferior"]*10  
# 
