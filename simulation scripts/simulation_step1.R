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

# get C-index
c_stat_current_step1 <- get_cstats(model = current_mod, 
                                   newdata = step1_dat,
                                   observed_outcome = "outcome_dysphagia_RT")

c_stat_extended_step1 <- get_cstats(model = extended_mod, 
                                    newdata = step1_dat,
                                    observed_outcome = "outcome_dysphagia_RT")
message("Step 1: c-index stored.")
rm(step1_dat)
