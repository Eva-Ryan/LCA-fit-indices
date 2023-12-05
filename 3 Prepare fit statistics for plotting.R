################################################################################
# Code to reformat the LatentGOLD output files created by fitting models to the
# datasets created in "1 Data generation.R" using the code in
# "2 Fit models in LatentGold.R" (note, I had to re-save the files outputted by
# LatentGOLD as new csv files so the data would load into R correctly). This
# code will generate a new output summary file containing just the relevant
# statistics for each fitted LCA model, the number of classes in the model, and
# which of the simulated datasets the model was fitted to. This output can
# then be used to generate summary plots and tables.
################################################################################

## load packages
library(tidyverse)

# get current working directory
directory <- getwd()

## function to load/reformat output file and add AIC/BIC/NFI
format_output <- function(file_names, max_class, N){
  # Inputs: file_names = naming convention for the folders/files relating to the
  #                      simulation of interest
  #         max_class = the maximum number of classes in the models fitted to
  #                     the simulated datasets
  # Outputs: df = reformatted LatentGOLD output dataframe with each row
  #               corresponding to a fitted model and columns representing the
  #               simulated dataset number, the number of classes in the model,
  #               the G^2 statistic for that model, and the AIC, BIC, and NFI

  # set working directory to where output file is saved
  setwd(paste0(directory, "/Simulations/", file_names))

  # read in the output file
  df <- read_csv(paste0(file_names, "_output_new.csv"), col_names = FALSE)

  # reduce dataframe to just rows with fit statistics
  df <- df %>%
    filter(X5 == "Statistics")

  # add simulation number and number of classes in models to dataframe
  df <- df %>%
    mutate(Number_of_classes = rep(1:max_class, times = 1000),
           Simulation_number = rep(1:1000, each = max_class))

  # remove columns that are all NA values (not fit statistics)
  df <- df %>%
    select_if(~any(!is.na(.)))

  # select just relevant columns - simulation number, number of classes, and
  # G^2 fit statistic
  df <- df %>%
    select(Simulation_number, Number_of_classes, X9)

  # rename columns to what statistic they represent
  names(df) <- c("Simulation_number", "Number_of_classes", "Gsquared")

  ## Add AIC/BIC/NFI measures

  # initialise AIC, BIC, and NFI columns
  df$AIC <- rep(NA, (1000*max_class))
  df$BIC <- rep(NA, (1000*max_class))
  df$NFI <- rep(NA, (1000*max_class))

  # select indices of rows corresponding to null models
  ind_null <- which(df$Number_of_classes == 1, arr.ind = TRUE)

  # for loop to cycle through the models with different numbers of classes and
  # calculate the AIC, BIC, and NFI
  for(i in 1:max_class){

    # select indices of rows where number of classes == i
    ind <- which(df$Number_of_classes == i, arr.ind = TRUE)

    # calculate number of free parameters (assuming 6 dichotomous items)
    P <- (i-1) + (i*6*1)

    # calculate AIC (using formulation from Collins & Lanza 2010)
    df$AIC[ind] <- df$Gsquared[ind] + 2*P

    # calculate BIC (using formulation from Collins & Lanza 2010)
    df$BIC[ind] <- df$Gsquared[ind] + log(N)*P

    # calculate NFI
    df$NFI[ind] <- (df$Gsquared[ind_null] - df$Gsquared[ind])/df$Gsquared[ind_null]

  }

  return(df)
}


## specify simulation
# sample size
N <- 5000
# max number of classes in fitted models
max_class <- 6
# folder/file naming convention
file_names <- paste0("sims_", N)

# reformat summary output file for chosen set of simulations
new_output <- format_output(file_names, max_class, N)

# save new output summary
write_csv(new_output, paste0(directory, "/Final output summaries/", file_names,
                             "_output_summary.csv"))

