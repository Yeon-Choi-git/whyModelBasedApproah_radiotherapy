
#=== list objects to save the simulation outputs
#= % of photon-only center
this_length <- nsim * length(cutoff_per)
saving_objects_names <- c(
  "delta",
  "per_proton",
  "per_proton_among_T3_4",
  "per_T3_4_among_proton",
  
  "NTCP_RT_true",
  "NTCP_RT_current",
  "NTCP_RT_extended",
  "NTCP_PT_true",
  
  "outcome_RT_true",
  "outcome_RT_current",
  "outcome_RT_extended",
  "outcome_PT_true",
  
  "riskdiff_true",
  "riskdiff_current",
  "riskdiff_extended",
  
  "or_true_list",
  "or_current_list",
  "or_extended_list",
  
  "c_stat_current_step2",
  "c_stat_extended_step2")

saving_objects <- setNames(lapply(
  saving_objects_names, 
  function(x) vector("list", this_length)), 
  saving_objects_names
)
list2env(saving_objects, envir = .GlobalEnv)


set.seed(seed_step2)
for (this_iter in 1:nsim){
  # print an iteration number at every 10 iteration
  cat("\rStep 2 simulation iteration at:", this_iter, "/", nsim)
  
  step2_dat_1 <- generate_data(n_step2)
  
  #======================================================#
  #===                    Step 2-1                    ===#
  #======================================================#
  #= predict NTCP-RT based on the current/extended NTCP model
  step2_dat_1[, NTCP_RT_current := predict(current_mod, step2_dat_1, type = "response")]
  step2_dat_1[, NTCP_RT_extended := predict(extended_mod, step2_dat_1, type = "response")]
  
  #= predict NTCP-PT based on the current/extended NTCP model
  predictors_name_rt <- colnames(extended_mod$model)[-1]
  predictors_name_pt <- gsub("RT_", "PT_", predictors_name_rt)
  step2_dat_1_pt <- step2_dat_1[, ..predictors_name_pt] #subset output predictors for NTCP under PT dose
  setnames(step2_dat_1_pt, predictors_name_pt, predictors_name_rt)
  step2_dat_1[, NTCP_PT_current := predict(current_mod, step2_dat_1_pt, type = "response")]
  step2_dat_1[, NTCP_PT_extended := predict(extended_mod, step2_dat_1_pt, type = "response")]
  rm(predictors_name_rt, predictors_name_pt, step2_dat_1_pt)
  
  
  for(this_cutoff in 1:length(cutoff_per)){
    #print(paste("scenario", scenario, "& delta NTCP cutoff at", cutoff_per[this_cutoff]))
    #======================================================#
    #===                    Step 2-2                    ===#
    #======================================================#
    #==== select proton-received patients based on the predefined cut-off
    if(setting %in% c("main", "A2", "A3")){
      # based on the predicted NTCP from the 'current' model
      step2_dat_2 <- step2_dat_1[NTCP_RT_current - NTCP_PT_current >= cutoff_per[this_cutoff], ]
    } else if (setting %in% c("A1")){
      # based on the predicted NTCP from the 'extended' model
      step2_dat_2 <- step2_dat_1[NTCP_RT_extended - NTCP_PT_extended >= cutoff_per[this_cutoff], ]
    }
    
    #= predicted binary outcomes under RT
    step2_dat_2[, outcome_dysphagia_RT_current := rbinom(nrow(step2_dat_2), 1, NTCP_RT_current)] 
    step2_dat_2[, outcome_dysphagia_RT_extended := rbinom(nrow(step2_dat_2), 1, NTCP_RT_extended)] 
    
    #======================================#
    #===      Summary statistics        ===#  
    #======================================#
    #save all the outputs
    save_here <- length(cutoff_per) * (this_iter - 1) + this_cutoff
    delta[[save_here]] <- cutoff_per[this_cutoff]
    
    # % of proton receiver
    per_proton[[save_here]] <- 100 * nrow(step2_dat_2)/nrow(step2_dat_1)
    
    # % of proton-received among higher T-stage
    per_proton_among_T3_4[[save_here]] <- 100 * sum(step2_dat_2[, t_stage])/sum(step2_dat_1[, t_stage])
    
    # % of higher T-stage among proton-received
    per_T3_4_among_proton[[save_here]] <- 100 * sum(step2_dat_2[, t_stage])/nrow(step2_dat_2)
    
    # binary outcome
    outcome_RT_true[[save_here]] <- mean(step2_dat_2[, outcome_dysphagia_RT])
    outcome_RT_current[[save_here]] <- mean(step2_dat_2[, outcome_dysphagia_RT_current])
    outcome_RT_extended[[save_here]] <- mean(step2_dat_2[, outcome_dysphagia_RT_extended])
    outcome_PT_true[[save_here]] <- mean(step2_dat_2[, outcome_dysphagia_PT])
    
    # NTCP
    NTCP_RT_true[[save_here]] <- mean(step2_dat_2[, NTCP_RT])
    NTCP_RT_current[[save_here]] <- mean(step2_dat_2[, NTCP_RT_current])
    NTCP_RT_extended[[save_here]] <- mean(step2_dat_2[, NTCP_RT_extended])
    NTCP_PT_true[[save_here]] <- mean(step2_dat_2[, NTCP_PT])
    
    #--- Treatment effects
    # Risk differences
    riskdiff_true[[save_here]] <- outcome_RT_true[[save_here]] - outcome_PT_true[[save_here]]
    riskdiff_current[[save_here]] <- outcome_RT_current[[save_here]] - outcome_PT_true[[save_here]]
    riskdiff_extended[[save_here]] <- outcome_RT_extended[[save_here]] - outcome_PT_true[[save_here]]
    
    # Odds ratios
    or_true_list[[save_here]] <- get_or(outcome_RT = step2_dat_2[, outcome_dysphagia_RT], 
                                        outcome_PT = step2_dat_2[, outcome_dysphagia_PT])
    or_current_list[[save_here]] <- get_or(outcome_RT = step2_dat_2[, outcome_dysphagia_RT_current], 
                                           outcome_PT = step2_dat_2[, outcome_dysphagia_PT])
    or_extended_list[[save_here]] <- get_or(outcome_RT = step2_dat_2[, outcome_dysphagia_RT_extended], 
                                            outcome_PT = step2_dat_2[, outcome_dysphagia_PT])
    
    # #c-stats
    c_stat_current_step2[[save_here]] <- get_cstats(model = NULL, 
                                                    newdata = step2_dat_2,
                                                    observed_outcome = "outcome_dysphagia_RT",
                                                    predicted_prob = "NTCP_RT_current")
    
    c_stat_extended_step2[[save_here]] <- get_cstats(model = NULL, 
                                                     newdata = step2_dat_2,
                                                     observed_outcome = "outcome_dysphagia_RT",
                                                     predicted_prob = "NTCP_RT_extended")
  }
}
rm(
  step2_dat_1,
  step2_dat_2,
  this_length,
  this_cutoff,
  this_iter
)
message("Step 2: Simluation finished.")

df_res <- data.table(
  delta,
  per_proton,
  per_proton_among_T3_4,
  per_T3_4_among_proton,

  outcome_RT_true,
  outcome_RT_current,
  outcome_RT_extended,
  outcome_PT_true,
  
  riskdiff_true,
  riskdiff_current,
  riskdiff_extended,
  
  or_true_list,
  or_current_list,
  or_extended_list,
  
  c_stat_current_step1,
  c_stat_extended_step1,

  c_stat_current_step2,
  c_stat_extended_step2
)

output_nam <- paste0("scenario_", setting, "_", scenario, ".csv")
fwrite(df_res, file = file.path("results", "raw output", output_nam))
rm(df_res, output_nam, saving_objects)
message(paste("Simulation outputs for", setting, scenario, "saved."))
message("-----------GO TO NEXT------------")

