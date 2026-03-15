#----------------------------------#
#-----        T stage         -----#
#----------------------------------#
per_stagelow <- 48.64629 
per_stagehigh <- 100 - per_stagelow 

#----------------------------------#
#----- primary tumor location -----#
#----------------------------------#
per_oral_cavity <- 5.764192 
per_pharynx <- 50.39301 
per_larynx <- 100 - (per_oral_cavity + per_pharynx) 

#----------------------------------#
#-----   Baseline dysphagia   -----#
#----------------------------------#
# An ordinal variable with three levels: 0-1, 2, 3plus
betas_baseline_dysphagia <- c(
  primary_tumor_larynx = -2.812328,
  primary_tumor_pharynx = -1.199732
)
intercetps_baseline_dysphagia <- c(
  "0-1|2" = -0.4409291, # 0-1|2 
  "2|3plus" = 1.0244321 # 2|3plus
)

#----------------------------------#
#-----    Photon dose (RT)    -----#
#----------------------------------#
if(isFALSE(tstage_to_dose)){ 
  #----- when T-stage does NOT affect the photon dose (RT)
  #----- in scenario 1 or all scenario's in setting 'A3'
  betas_RT_oral_cavity <- c(
    intercept = 57.531,
    t_stage = 0,
    primary_tumor_larynx = -41.439, 
    primary_tumor_pharynx = -8.474
  )
  error_RT_oral_cavity = 13.55921
  
  betas_RT_PCM_superior <- c(
    intercept = 50.285,
    t_stage = 0,
    primary_tumor_larynx = -29.387, 
    primary_tumor_pharynx = 8.125
  ) 
  error_RT_PCM_superior = 14.83953
  
  betas_RT_PCM_medius <- c(
    intercept = 48.26,
    t_stage = 0,
    primary_tumor_larynx = -10.12, 
    primary_tumor_pharynx = 10.19
  ) 
  error_RT_PCM_medius = 17.66849
  
  betas_RT_PCM_inferior <- c(
    intercept = 41.766,
    t_stage = 0,
    primary_tumor_larynx = 18.540, 
    primary_tumor_pharynx = 8.417
  ) 
  error_RT_PCM_inferior = 12.1194
  
} else if(isTRUE(tstage_to_dose)) {
  #----- when T-stage affects the photon dose (RT)
  #----- in scenario 2-4 in the setting 'main', 'A1', and 'A2'
  betas_RT_oral_cavity <- c(
    intercept = 48.63,
    t_stage = 12.77 * multiplier_tstage_to_dose,
    primary_tumor_larynx = -37.78, 
    primary_tumor_pharynx = -7.01
  )
  error_RT_oral_cavity = 12.02239
  
  betas_RT_PCM_superior <- c(
    intercept = 40.413,
    t_stage = 14.165 * multiplier_tstage_to_dose,
    primary_tumor_larynx = -25.327, 
    primary_tumor_pharynx = 9.749
  ) 
  error_RT_PCM_superior = 13.10922
  
  betas_RT_PCM_medius <- c(
    intercept = 36.537,
    t_stage = 16.821 * multiplier_tstage_to_dose,
    primary_tumor_larynx = -5.302, 
    primary_tumor_pharynx = 12.116
  ) 
  error_RT_PCM_medius = 15.61975
  
  betas_RT_PCM_inferior <- c(
    intercept = 37.404,
    t_stage = 6.259 * multiplier_tstage_to_dose,
    primary_tumor_larynx = 20.334, 
    primary_tumor_pharynx = 9.135
  )
  error_RT_PCM_inferior = 11.72338
  
}

#----------------------------------#
#-----     Dose reduction     -----#
#----------------------------------#
if(isFALSE(tstage_to_dosediff)){  
  #----- when primary tumor location affects dose reduction between from photon to proton
  #----- in setting 'main', 'A1'
  betas_diff_oral_cavity <- c(
    intercept = 7.427,
    primary_tumor_larynx = 6.325, 
    primary_tumor_pharynx = 5.081
  )
  error_diff_oral_cavity <- 5.363181
  
  betas_diff_PCM_superior <- c(
    intercept = 8.127,
    primary_tumor_larynx = 4.740, 
    primary_tumor_pharynx = -3.121
  )
  error_diff_PCM_superior <- 4.721894
  
  betas_diff_PCM_medius <- c(
    intercept = 7.308,
    primary_tumor_larynx = 0.638, 
    primary_tumor_pharynx = -3.018
  )
  error_diff_PCM_medius <- 4.940534
  
  betas_diff_PCM_inferior <- c(
    intercept = 8.391,
    primary_tumor_larynx = -4.985, 
    primary_tumor_pharynx = -1.232
  )
  error_diff_PCM_inferior <- 4.940534
  
} else if (isTRUE(tstage_to_dosediff)){
  #----- when T-stage affects dose reduction between from photon to proton
  #----- in setting 'A2' and 'A3'
  betas_diff_oral_cavity <- c(
    intercept = 14.342,
    t_stage = -3.036
  )
  error_diff_oral_cavity <- 5.421675
  
  betas_diff_PCM_superior <- c(
    intercept = 6.8621,
    t_stage = 0.2974
  )
  error_diff_PCM_superior <- 5.735203
  
  betas_diff_PCM_medius <- c(
    intercept = 6.005,
    t_stage = -0.926
  )
  error_diff_PCM_medius <- 5.735203 
  
  betas_diff_PCM_inferior <- c(
    intercept = 8.518,
    t_stage = -3.143
  )
  error_diff_PCM_inferior <- 5.177222 
  
}

#----------------------------------#
#-----    Outcome dysphagia   -----#
#----------------------------------#
betas_outcome_dysphagia <- if(scenario == "1"){
  # T-stage is NOT an outcome predictor
  c(intercept = -4.04888,
    primary_tumor_larynx = -0.72516,
    primary_tumor_pharynx = -0.57230, 
    baseline_dysphagia_2 = 0.98360,
    baseline_dysphagia_3plus = 1.59422,
    RT_oral_cavity = 0.04032,
    RT_PCM_superior = 0.00823, 
    RT_PCM_medius = 0.01220,
    RT_PCM_inferior = 0.01530,
    t_stage = 0
  )
} else if (scenario %in% c("2", "3.1", "3.2", "4.1", "4.2")){
  # T-stage is an outcome predictor
  c(intercept = -3.859040,
    primary_tumor_larynx = -0.805187,
    primary_tumor_pharynx = -0.562425, 
    baseline_dysphagia_2 = 0.921005,
    baseline_dysphagia_3plus = 1.509292,
    RT_oral_cavity = 0.036291,
    RT_PCM_superior = 0.008349, 
    RT_PCM_medius = 0.010691,
    RT_PCM_inferior = 0.012858,
    t_stage = 0.374959 * multiplier_tstage_to_outcome
  )
}

message(paste("Data generation coefficients for", setting, scenario, "is loaded."))
