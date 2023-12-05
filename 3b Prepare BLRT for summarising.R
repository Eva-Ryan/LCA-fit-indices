################################################################################
# Code to reformat the LatentGOLD output files created by fitting models to the
# datasets created in "1 Data generation.R" and running the BLRT using the code
# in the two "2b Run BLRT in LatentGold" R scripts. This code will generate a
# new output summary file containing just the BLRT result for each fitted LCA
# model, the number of classes in the model, and which of the simulated datasets
# the model was fitted using. This output can then be used to generate summary
# tables.
################################################################################

## load packages
library(tidyverse)

# get current working directory
directory <- getwd()

## function to load/reformat BLRT output file
format_output_BLRT <- function(file_names, max_class, N){
  # Inputs: file_names = naming convention for the folders/files relating to the
  #                      simulation of interest
  #         max_class = the maximum number of classes in the models fitted to
  #                     the simulated datasets
  # Outputs: df = reformatted LatentGOLD output dataframe with each row
  #               corresponding to a fitted model and columns representing the
  #               simulated dataset number, the number of classes in the model,
  #               and the BLRT p-value

  # set working directory to where the BLRT output file is saved
  setwd(paste0(directory, 'Simulations/', file_names, "/BLRT"))

  # read in the output files from BLRT
  df1 <- read_csv(paste0(file_names, "_output_BLRT.csv"), col_names = FALSE)
  df2 <- read_csv(paste0(file_names, "_output_BLRT_2.csv"), col_names = FALSE)

  ## reduce dataframe to just rows with BLRT results summary

  # remove irrelevant columns
  df1 <- df1 %>%
    select(-X2, -X3, -X4)
  df2 <- df2 %>%
    select(-X2, -X3, -X4)

  # remove empty rows
  df1 <- df1 %>%
    filter(is.na(X5) == FALSE)
  df2 <- df2 %>%
    filter(is.na(X5) == FALSE)

  # extract first word of the merged columns, so can then filter to just
  # Bootstrap rows
  df1$Statistics <- sub("(.*?)\\,.*", "\\1", df1$X5)
  df2$Statistics <- sub("(.*?)\\,.*", "\\1", df2$X5)

  # filter both dataframes to just rows containing Bootstrap stats
  df1 <- df1 %>%
    filter(Statistics == "Bootstrap")
  df2 <- df2 %>%
    filter(Statistics == "Bootstrap")

  # combine into one dataframe
  df <- rbind(df1, df2)

  # add simulation number and number of classes in models to dataframe
  df <- df %>%
    mutate(Number_of_classes = rep(1:max_class, times = 1000),
           Simulation_number = rep(1:1000, each = max_class))

  # extract p-value of BLRT for each model
  df$BLRT_p_value <- trimws(trimws(df$X5, "left", "\\w"), "left", ",")

  # select just relevant columns
  df <- df %>%
    select(Simulation_number, Number_of_classes, BLRT_p_value)

  return(df)
}


## specify simulation
# sample size
N <- 10000
# max number of classes in fitted models
max_class <- 6
# folder/file naming convention
file_names <- paste0("sims_", N)

# reformat summary output file for chosen set of simulations
new_output <- format_output_BLRT(file_names, max_class, N)

# save new output summary
write_csv(new_output, paste0(directory, "/Final output summaries/", file_names,
                             "_BLRT_summary.csv"))

