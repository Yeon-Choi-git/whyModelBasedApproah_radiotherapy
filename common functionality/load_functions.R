all_files <- list.files(
  path = file.path("common functionality", "functions"), 
  full.names = TRUE, recursive = TRUE)

for(fl in all_files){
  source(fl)
}

logr::log_print("Funcitons loaded.")

rm(all_files, fl)
