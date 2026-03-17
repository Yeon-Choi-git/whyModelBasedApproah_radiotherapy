# This script combines raw simulations results and take mean across all 
# iterations, and save a table output which contains information supplied in
# Table 1, Appendix B, and Appendix E.

fin_results_shell <- NULL
for(i in 1:length(scenario_list)){
  this_scenario <- scenario_list[i]
  
  this_file <- paste0("scenario_", setting, "_", this_scenario, ".csv")
  this_results <- as.data.table(fread(file.path("results", "raw output", this_file), header = TRUE)) 
  
  this_summary <- this_results %>%
    mutate(delta = factor(delta)) %>% 
    group_by(delta) %>% 
    dplyr::summarise(mean_per_proton = mean(per_proton),
                     mean_per_proton_among_T3_4 = mean(per_proton_among_T3_4),
                     mean_per_T3_4_among_proton = mean(per_T3_4_among_proton),
                     
                     # c-stats
                     c_stat_current_step1  = mean(c_stat_current_step1),
                     c_stat_extended_step1 = mean(c_stat_extended_step1),
                     
                     mean_c_stat_current_step2 = mean(c_stat_current_step2),
                     sd_c_stat_current_step2 = sd(c_stat_current_step2),
                     mean_c_stat_extended_step2 = mean(c_stat_extended_step2),
                     sd_c_stat_extended_step2 = sd(c_stat_extended_step2),
                     
                     # risk difference
                     mean_riskdiff_true = mean(riskdiff_true),
                     sd_riskdiff_true = sd(riskdiff_true),
                     
                     mean_riskdiff_current = mean(riskdiff_current),
                     sd_riskdiff_current = sd(riskdiff_current),
                     
                     mean_riskdiff_extended = mean(riskdiff_extended),
                     sd_riskdiff_extended = sd(riskdiff_extended),
                     
                     # risk difference bias (against RD NTCP)
                     mean_bias_riskdiff_current = mean(riskdiff_current - riskdiff_true),
                     sd_bias_riskdiff_current = sd(riskdiff_current - riskdiff_true),
                     mse_riskdiff_current = mean((riskdiff_current - riskdiff_true)^2),
                     
                     mean_bias_riskdiff_extended = mean(riskdiff_extended - riskdiff_true),
                     sd_bias_riskdiff_extended = sd(riskdiff_extended - riskdiff_true),
                     mse_riskdiff_extended = mean((riskdiff_extended - riskdiff_true)^2),
                     
                     # OR
                     mean_or_true = mean(or_true_list),
                     sd_or_true = sd(or_true_list),
                     
                     mean_or_current = mean(or_current_list),
                     sd_or_current = sd(or_current_list),
                     
                     mean_or_extended = mean(or_extended_list),
                     sd_or_extended = sd(or_extended_list),
                     
                     # OR bias
                     mean_bias_log_or_current = mean(log(or_current_list) - log(or_true_list)),
                     sd_bias_log_or_current =  sd(log(or_current_list) - log(or_true_list)),
                     mse_log_or_current = mean((log(or_current_list) - log(or_true_list))^2),
                     
                     mean_bias_log_or_extended = mean(log(or_extended_list) - log(or_true_list)),
                     sd_bias_log_or_extended = sd(log(or_extended_list) - log(or_true_list)),
                     mse_log_or_extended = mean((log(or_extended_list) - log(or_true_list))^2)
                     
    ) %>% 
    mutate(scenario = scenario_list[i]) %>% 
    relocate(scenario) %>% 
    ungroup
  
  fin_results_shell <- rbind(fin_results_shell, this_summary)
}

#------------- format numbers and cells -----------#
setDT(fin_results_shell)

# round variables to relevant digits
# round to 1 digits
round_1digit <- c("mean_per_proton", "mean_per_proton_among_T3_4", "mean_per_T3_4_among_proton")
fin_results_shell[
  ,
  (round_1digit) := lapply(.SD, \(x) formatC(x, format = "f", digits = 1)),
  .SDcols = round_1digit
]
# round to 3 digits
round_3digit <- names(fin_results_shell)[grepl("mean_|sd_|mse_", names(fin_results_shell))]
round_3digit <- round_3digit[!round_3digit %in% round_1digit]
fin_results_shell[
  ,
  (round_3digit) := lapply(.SD, \(x) formatC(x, format = "f", digits = 3)),
  .SDcols = round_3digit
]

# combine mean and sd values into one cell 
fin_results_shell_fin <- fin_results_shell %>% 
  mutate(
    c_stat_current_step2 = paste0(mean_c_stat_current_step2, " (", sd_c_stat_current_step2, ")"),
    c_stat_extended_step2 = paste0(mean_c_stat_extended_step2, " (", sd_c_stat_extended_step2, ")"),
    
    riskdiff_true = paste0(mean_riskdiff_true, " (", sd_riskdiff_true, ")"),
    riskdiff_current = paste0(mean_riskdiff_current, " (", sd_riskdiff_current, ")"),
    riskdiff_extended = paste0(mean_riskdiff_extended, " (", sd_riskdiff_extended, ")"), 
    
    bias_riskdiff_current = paste0(mean_bias_riskdiff_current, " (", mse_riskdiff_current, ")"),
    bias_riskdiff_extended = paste0(mean_bias_riskdiff_extended, " (", mse_riskdiff_extended, ")"),
    
    or_true = paste0(mean_or_true, " (", sd_or_true, ")"),
    or_current = paste0(mean_or_current, " (", sd_or_current, ")"),
    or_extended = paste0(mean_or_extended, " (", sd_or_extended, ")"),
    
    bias_or_current = paste0(mean_bias_log_or_current, " (", mse_log_or_current, ")"),
    bias_or_extended = paste0(mean_bias_log_or_extended, " (", mse_log_or_extended, ")")
  ) %>% 
  dplyr::select(scenario,
                delta,
                mean_per_proton,
                mean_per_proton_among_T3_4,
                mean_per_T3_4_among_proton,
                
                c_stat_current_step1,
                c_stat_extended_step1,
                c_stat_current_step2,
                c_stat_extended_step2,
                
                riskdiff_true ,
                riskdiff_current ,
                riskdiff_extended ,    
                
                bias_riskdiff_current ,
                bias_riskdiff_extended ,
                
                or_true ,
                or_current ,
                or_extended ,
                
                bias_or_current,
                bias_or_extended
  )

output_nam <- paste0("combined_", setting, ".csv")
fwrite(fin_results_shell_fin , file.path("results", "tables", output_nam))
rm(this_scenario, this_file, this_results, this_summary, fin_results_shell,
   round_1digit, round_3digit, fin_results_shell_fin, output_nam)

message(paste("Summary table for", setting, "saved."))

