install_package_fun <- function(name_fun) {
  package_name <- as.character(name_fun)
  if (!require(package_name, character.only = TRUE)) {
    install.packages(package_name, dependencies = TRUE)
  }
  suppressPackageStartupMessages(library(package_name, character.only = TRUE))
}


list_of_packages <- c("dplyr",
                      "plyr",
                      "data.table",
                      "tidyr",
                      "MASS",
                      "predtools",
                      "DescTools",
                      "Hmisc",
                      "ggplot2",
                      "ggpubr",
                      "ggExtra",
                      "haven",
                      "logr",
                      "truncnorm") 

lapply(list_of_packages, function(package_name) {
  install_package_fun(package_name)}
)

logr::log_print("Packages loaded.")
rm(list_of_packages, install_package_fun)
