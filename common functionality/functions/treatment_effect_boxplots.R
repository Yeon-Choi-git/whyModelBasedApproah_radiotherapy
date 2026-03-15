# make a box plot for a simulation setting
# it returns a combined plot with each scenario in a column

make_boxplots <- function(
    input_dat,
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
){
  ggplot(
    input_dat, 
    aes(x =  .data[[aes_x]], y = .data[[aes_y]], fill = .data[[aes_fill]])) +
    ylim(ylim[1], ylim[2]) +
    labs(title = title) +
    ylab(ylab) +
    xlab(xlab) +
    geom_boxplot(outlier.size = 0.1) +
    theme_bw() +
    theme(text = element_text(size = 10),
          axis.text=element_text(size = 10),
          legend.text = element_text(size = 10)) +
    guides(fill = guide_legend(title = "")) +
    scale_fill_manual(labels = labels,
                      values = colors,
                      guide = guide_legend(label.hjust = 0.5)) +
    scale_x_discrete(labels = scale_x_discrete)
  
}
