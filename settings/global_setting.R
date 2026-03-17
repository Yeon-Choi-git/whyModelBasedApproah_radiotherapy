#======= Set global simulation settings =======#
#--- Number of observations for each step.
n_step1 <- 50000 # Step 1: model development
n_step2 <- 5000  # Step 2: model validation

# Which cutoff for predicted ∆NTCP to use for selection proton patients?
# Use values between 0 to 1
cutoff_per <- c(0, 0.1, 0.2) 

# How many simulation iterations to run for Step 2?
# The paper used 1000
nsim <- 100

# Set seeds
seed_step1 <- NULL  
seed_step2 <- NULL 

#===== Which settings & scenarios to run? =====#
# possible settings to add: "main", "A1", "A2", "A3"
# possible scenario to add: "1", "2", "3.1", "3.2", "4.1", "4.2"
setting_list <- c("main", "A1", "A2", "A3") 
scenario_list <- c("1", "2", "3.1", "3.2", "4.1", "4.2")