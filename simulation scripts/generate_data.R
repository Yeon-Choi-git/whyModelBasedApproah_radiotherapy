
generate_data <- function(n){
  id <- 1:n
  dose_parameters <- c("oral_cavity", "PCM_superior",  "PCM_medius", "PCM_inferior")
  sim_dat <- data.table()
  
  #----------------------------------#
  #-----        T stage         -----#
  #----------------------------------#
  #0: low (Tis-2)
  #1: high (T3-4)
  t_stage <- rbinom(n, 1, prob = per_stagehigh/100)
  
  #----------------------------------#
  #----- primary tumor location -----#
  #----------------------------------#
  df_primary_tumor <- rmultinom(n, 1, c(per_oral_cavity, per_pharynx, per_larynx)/100)
  primary_tumor_oral_cavity <- df_primary_tumor[1, ]
  primary_tumor_pharynx <- df_primary_tumor[2, ]
  primary_tumor_larynx <- df_primary_tumor[3, ]
  
  # also save into a factor variable
  primary_tumor_location <- rep(NA, n)
  primary_tumor_location[primary_tumor_oral_cavity == 1] = "oral cavity"
  primary_tumor_location[primary_tumor_pharynx == 1] = "pharynx"
  primary_tumor_location[primary_tumor_larynx == 1] = "larynx"
  primary_tumor_location <- factor(primary_tumor_location, levels = c("oral cavity", "pharynx", "larynx"))
  
  # into a dataset
  sim_dat <- data.table(id, t_stage, primary_tumor_location, primary_tumor_oral_cavity, primary_tumor_pharynx, primary_tumor_larynx)
  
  #----------------------------------#
  #-----   Baseline dysphagia   -----#
  #----------------------------------#
  # An ordinal variable with three levels: 0-1, 2, 3plus
  # save the linear predictor of all subjects
  predictors <- names(betas_baseline_dysphagia)
  linear_pred <- drop(
    as.matrix(sim_dat[, ..predictors]) %*% 
      betas_baseline_dysphagia
  )
  
  # get cumulative probabilities of the ordinal logistic
  cumprob <- plogis(outer(linear_pred, intercetps_baseline_dysphagia, function (x, y) y - x))
  
  # get probabilities for each category of baseline dysphagia
  predicted_prob <- cbind(
    "0-1" = cumprob[, 1],              # 0-1
    "2" = cumprob[, 2] - cumprob[, 1], # 2
    "3plus" = 1 - cumprob[, 2]         # 3plus
  )
  
  # add to the data
  sim_dat[, baseline_dysphagia := factor(
    apply(
      predicted_prob,
      1,
      function(p) sample(names(p), size = 1, prob = p)
    ), level = c("0-1", "2", "3plus")
  )
  ]
  
  # also into a dummy variables
  sim_dat[, baseline_dysphagia_0_1 := ifelse(baseline_dysphagia == "0-1", 1, 0)]
  sim_dat[, baseline_dysphagia_2 := ifelse(baseline_dysphagia == "2", 1, 0)]
  sim_dat[, baseline_dysphagia_3plus := ifelse(baseline_dysphagia == "3plus", 1, 0)]
  
  #----------------------------------#
  #-----    Photon dose (RT)    -----#
  #----------------------------------#
  rt_dose_parameters <- paste0("RT_",dose_parameters)
  for(thisvar in rt_dose_parameters){
    # call betas for photon dose of this dose parameter
    betas_thisvar <- eval(parse(text = paste0("betas_", thisvar)))
    predictors <- names(betas_thisvar)[-1]
    # select the predictor columns and multiply with the predictors and add random variability
    dose <- drop(
      as.matrix(bind_cols(intercept = 1L, sim_dat[, ..predictors])) %*% 
        betas_thisvar + 
        rnorm(n, 0, eval(parse(text = paste0("error_", thisvar))))
    )
    # RT dose lower than 5 ->> assign a random dosage between 0-5
    dose[dose <= 5] <- runif(length(dose[dose <= 5]), min = 0, max = 5) 
    sim_dat[, (thisvar) := dose]
  }
  
  #----------------------------------#
  #-----     Dose reduction     -----#
  #----------------------------------#
  diffdose_parameters <- paste0("diff_", dose_parameters)
  for(thisvar in diffdose_parameters){
    # call betas for photon dose of this dose parameter
    betas_thisvar <- eval(parse(text = paste0("betas_", thisvar)))
    predictors <- names(betas_thisvar)[-1]
    # select the predictor columns and multiply with the predictors and add random variability
    dose <- drop(
      as.matrix(bind_cols(intercept = 1L, sim_dat[, ..predictors])) %*% 
        betas_thisvar + 
        rnorm(n, 0, eval(parse(text = paste0("error_", thisvar))))
    )
    # RT dose lower than 5 ->> assign a random dosage between 0-5
    dose[dose <= 5] <- runif(length(dose[dose <= 5]), min = 0, max = 5) 
    sim_dat[, (thisvar) := dose]
  }
  
  #----------------------------------#
  #-----    Proton dose (PT)    -----#
  #----------------------------------#
  for(thisvar in dose_parameters){
    dose <- sim_dat[[paste0("RT_", thisvar)]] - sim_dat[[paste0("diff_", thisvar)]]
    dose[dose < 0] <- 0 # if PT dose is negative, assign 0
    sim_dat[, (paste0("PT_", thisvar)) := dose]
  }
  
  #----------------------------------#
  #-----     Dysphagia at 6m    -----#
  #----------------------------------#
  # under PHOTON (RT)
  predictors <- names(betas_outcome_dysphagia)[-1]
  linear_pred <- drop(
    as.matrix(bind_cols(intercept = 1L, sim_dat[, ..predictors])) %*% 
      betas_outcome_dysphagia
  )
  sim_dat[, NTCP_RT := plogis(linear_pred)]
  sim_dat[, outcome_dysphagia_RT := rbinom(n, 1, prob = NTCP_RT)]
  
  # under PROTON (PT)
  predictors <- gsub("RT_", "PT_", names(betas_outcome_dysphagia)[-1])
  linear_pred <- drop(
    as.matrix(bind_cols(intercept = 1L, sim_dat[, ..predictors])) %*% 
      betas_outcome_dysphagia
  )
  sim_dat[, NTCP_PT := plogis(linear_pred)]
  sim_dat[, outcome_dysphagia_PT := rbinom(n, 1, prob = NTCP_PT)]
  
  return(sim_dat)
}


