################################################################################
# Code to determine for what percentage of the 1000 replicate simulations the
# BLRT selects each number of classes considered (1 to 6) as the best fit,
# using the summary output files generated using the code in
# "2b Run BLRT in LatentGold.R".
################################################################################

# load tidyverse package
library(tidyverse)

# get current working directory
directory <- getwd()

## function to apply criteria and calculate how often each number of classes is
# chosen as a percentage
apply_criteria_BLRT <- function(file_names, max_class, N){
  # Inputs: file_names = naming convention for the folders/files relating to the
  #                      simulation of interest
  #         max_class = the maximum number of classes in the models fitted to
  #                     the simulated datasets
  #         N = sample size for the simulations
  # Outputs: results = summary table of how often the criteria for the BLRT
  #                    selected each number of classes as being the best fit for
  #                    the simulated data

  # set working directory to where the BLRT summary is saved
  setwd(paste0(directory, '/Final output summaries'))

  # read in output summary file for BLRT
  df <- read_csv(paste0(file_names, "_BLRT_summary.csv"))

  # add a new column to the dataset to populated with a 1 if the BLRT criteria
  # selected the model corresponding to that row, or a zero otherwise
  df$BLRT_select <- 0

  # for loop to cycle through each simulated dataset and determine which model
  # (between 1 and 6 classes) provides the best fit as per the BLRT criteria
  # of the first model with a p-value > 0.05 to not reject the null hypothesis
  for(i in 1:1000){

    # select the row indices of just the models fitted to simulation i
    ind <- which(df$Simulation_number == i, arr.ind = TRUE)

    # set up while loop to cycle through models with different numbers of classes
    # until criteria is satisfied (or if not satisfied, pick model with most
    # classes)

    # indicator if while loop should continue or not
    continue <- 0

    # variable to keep track of number of classes in model
    c <- 1

    while(continue == 0){

      # check if BLRT p-value is > 0.05
      if( df$BLRT_p_value[ind[c]] > 0.05){

        # select the c-1 class model as the best
        df$BLRT_select[ind[c-1]] <- 1

        # change continue to 1 to stop the while loop
        continue <- 1

      }else{

        # otherwise, if c is not the maximum number of classes, increase c by 1
        # and loop again
        if(c < max_class){

          c <- c + 1

        }else{

          # if c is equal to the maximum number of classes and the criteria
          # still hasn't been met, select c as the best number of classes and
          # stop the while loop
          df$BLRT_select[ind[c]] <- 1
          continue <- 1

        }
      }
    }
  }

  ## calculate percentage of times each number of classes is chosen by the BLRT

  # create dataframe to store results
  results <- as.data.frame(matrix(NA, nrow = 1, ncol = max_class))
  names(results) <- 1:6
  row.names(results) <- c("BLRT")

  # loop through classes calculating percentages
  for(c in 1:max_class){

    # filter to just rows corresponding to models with c classes
    df_c <- df %>%
      filter(Number_of_classes == c)

    # populate results dataframe with percentage of simulations the BLRT
    # selected c classes for
    results[1, c] <- paste0(round((sum(df_c$BLRT_select)/1000)*100, 1), "%")

  }

  # return dataframe of results
  return(results)

}

## create summaries for each sample size N
summary_500 <- apply_criteria_BLRT(file_names = paste0("sims_", 500),
                              max_class = 6, N = 500)
summary_5000 <- apply_criteria_BLRT(file_names = paste0("sims_", 5000),
                               max_class = 6, N = 5000)
summary_10000 <- apply_criteria_BLRT(file_names = paste0("sims_", 10000),
                                max_class = 6, N = 10000)
summary_30000 <- apply_criteria_BLRT(file_names = paste0("sims_", 30000),
                                max_class = 6, N = 30000)
summary_100000 <- apply_criteria_BLRT(file_names = paste0("sims_", 100000),
                                 max_class = 6, N = 100000)

# display the summaries
summary_500
summary_5000
summary_10000
summary_30000
summary_100000

