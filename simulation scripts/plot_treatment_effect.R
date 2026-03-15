# combine all raw simulation results into one data set
fin_results <- list()
for(j in 1:length(scenario_list)){
  this_scenario <- scenario_list[j]
  
  this_file <-  paste0("scenario_", setting, "_", this_scenario, ".csv")
  this_results <- as.data.table(fread(file.path(results_dir, this_file), header = TRUE)) 
  
  this_results[, scenario := this_scenario]
  fin_results[[j]] <- this_results
}
fin_results <- rbindlist(fin_results)


#-------------------- plot risk differences ------------------------#
cutoff_lables <- paste0(cutoff_per*100, "%")
plot_rd <- vector("list", length = length(scenario_list))
plot_or <- vector("list", length = length(scenario_list))

#pdf("ATT_riskdiff_plot.pdf")
for(i in 1:length(scenario_list)){
  this_scenario <- scenario_list[i]  
  
  this_subset <- subset(fin_results, scenario == scenario_list[i])
  
  df_boxplot_rd <- this_subset[, c("scenario",
                                   "delta",
                                   "riskdiff_true",
                                   "riskdiff_current",
                                   "riskdiff_extended")] %>%
    dplyr::rename(true = riskdiff_true,
                  current = riskdiff_current,
                  extended = riskdiff_extended) %>%
    mutate(ntcp_cutoff = as.factor(unlist(delta))) %>%
    pivot_longer(cols = c("true", "current", "extended"),
                 names_to = "model",
                 values_to = "treatment_effect") %>%
    mutate(model = factor(model, levels = c("true", "current", "extended")))
  
  df_boxplot_or <- this_subset[, c("scenario",
                                   "delta",
                                   "or_true_list",
                                   "or_current_list",
                                   "or_extended_list")] %>%
    dplyr::rename(true = or_true_list,
                  current = or_current_list,
                  extended = or_extended_list) %>%
    mutate(ntcp_cutoff = as.factor(unlist(delta))) %>%
    pivot_longer(cols = c("true", "current", "extended"),
                 names_to = "model",
                 values_to = "treatment_effect") %>%
    mutate(model = factor(model, levels = c("true", "current", "extended")))
  
  
  plot_rd[[i]] <- make_boxplots (
    input_dat = df_boxplot_rd,
    aes_x = "ntcp_cutoff",
    aes_y = "treatment_effect",
    aes_fill = "model",
    labels = c("True effect", "Current model", "Extended model"),
    colors = c("darkgrey", "#ffc300", "#00798c"),
    title = paste("Scenario", this_scenario),
    ylab = "",
    xlab = "∆NTCP threshold",
    ylim = c(0.07, 0.33),
    scale_x_discrete = cutoff_lables
  )
  
  plot_or[[i]] <- make_boxplots (
    input_dat = df_boxplot_or,
    aes_x = "ntcp_cutoff",
    aes_y = "treatment_effect",
    aes_fill = "model",
    labels = c("True effect", "Current model", "Extended model"),
    colors = c("darkgrey", "#ffc300", "#00798c"),
    title = paste("Scenario", this_scenario),
    ylab = "",
    xlab = "∆NTCP threshold",
    ylim = c(0.25, 0.75),
    scale_x_discrete = cutoff_lables
  ) 
  
}

plot_rd_combined <- ggpubr::ggarrange(
  plot_rd[[1]], 
  plot_rd[[2]],
  plot_rd[[3]],
  plot_rd[[4]],
  plot_rd[[5]],
  plot_rd[[6]],
  ncol = length(scenario_list), nrow = 1,
  common.legend = TRUE,
  legend = "bottom")

plot_rd_combined <- annotate_figure(
  plot_rd_combined, 
  top = text_grob(paste0("Treatment effect in risk difference"), 
                  face = "bold", 
                  size = 11),
  left = text_grob(setting, rot = 90))
print(plot_rd_combined)  

plot_or_combined <- ggpubr::ggarrange(
  plot_or[[1]], 
  plot_or[[2]],
  plot_or[[3]],
  plot_or[[4]],
  plot_or[[5]],
  plot_or[[6]],
  ncol = length(scenario_list), nrow = 1,
  common.legend = TRUE,
  legend = "bottom")

plot_or_combined <- annotate_figure(
  plot_or_combined, 
  top = text_grob(paste0("Treatment effect in odds ratio"), 
                  face = "bold", 
                  size = 11),
  left = text_grob("Odds ratio", rot = 90))
print(plot_or_combined)  

#dev.off()
