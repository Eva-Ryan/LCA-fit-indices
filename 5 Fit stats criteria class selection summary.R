################################################################################
# Code to determine for what percentage of the 1000 replicate simulations the
# AIC, BIC, and NFI select each number of classes considered (1 to 6) as the
# best fit. Uses the summary output files created in "3 Prepare fit statistics
# for plotting.R".
################################################################################

# load tidyverse package
library(tidyverse)

# get current working directory
directory <- getwd()

## function to apply criteria and calculate how often each number of classes is
# chosen as a percentage
apply_criteria <- function(file_names, max_class, N){
  # Inputs: file_names = naming convention for the folders/files relating to the
  #                      simulation of interest
  #         max_class = the maximum number of classes in the models fitted to
  #                     the simulated datasets
  #         N = sample size for the simulations
  # Outputs: results = summary table of how often the criteria for each fit
  #                    measure selected each number of classes as being the
  #                    best fit for the simulated data

  # set working directory to where fit index summaries are saved
  setwd(paste0(directory, "/Final output summaries"))

  # read in summary of simulation models fit stats
  df <- read_csv(paste0(file_names, "_output_summary.csv"))

  # add a new column to the dataset for each fit measure - these columns will be
  # populated with a 1 if the criteria select the model corresponding to that row,
  # or a zero otherwise
  df$AIC_select <- 0
  df$AIC_select_2 <- 0
  df$BIC_select <- 0
  df$BIC_select_2 <- 0
  df$NFI_select <- 0
  df$NFI_select_cutoff <- 0

  # add a column to the dataset to store the difference in NFI value between
  # the model in that row and the previous model, i.e., the increase in NFI
  # for adding an extra class
  df$NFI_diff <- NA

  # loop through each simulation
  for(i in 1:1000){

    # select the row indices of just the models fitted to simulation i
    ind <- which(df$Simulation_number == i, arr.ind = TRUE)

    # calculate the increase in NFI for models with 2-6 classes
    df$NFI_diff[ind[2:6]] <- df$NFI[ind[2:max_class]] - df$NFI[ind[1:(max_class - 1)]]

  }

  # for loop to cycle through each simulated dataset and determine which model
  # (between 1 and 6 classes) provides the best fit as per the AIC and BIC
  # criteria of achieving the lowest AIC/BIC value
  for(i in 1:1000){

    # select the row indices of just the models fitted to simulation i
    ind <- which(df$Simulation_number == i, arr.ind = TRUE)


    #---------------------------------------------------------------------------
    # AIC

    # select the row index of the model with the lowest AIC value for simulation
    # i and set AIC_select = 1 for that model
    model_lowest_AIC <- which(df$AIC[ind] == min(df$AIC[ind]), arr.ind = TRUE)
    ind_AIC <- ind[model_lowest_AIC]
    df$AIC_select[ind_AIC] <- 1

    # select the most parsimonious model with AIC within 2 of the lowest AIC
    # value

    # set AIC_select_2 equal to AIC_select by default
    df$AIC_select_2[ind_AIC] <- 1

    # create variable to track if the while loop should continue
    continue <- 0

    # create variable to track number of classes in smaller model
    c <- 1

    # check if there is a simpler model with AIC within 2 of the min -
    # if there is, change AIC_select_2 to 1 for that model and to 0 for the
    # AIC_select model
    while((continue == 0) & (c < model_lowest_AIC)){
      if(df$AIC[ind[c]] - df$AIC[ind_AIC] < 2){

        df$AIC_select_2[ind[c]] <- 1
        df$AIC_select_2[ind_AIC] <- 0

        continue <- 1

      }else{

        c <- c + 1

      }
    }


    #---------------------------------------------------------------------------
    # BIC

    # select the row index of the model with the lowest BIC value for simulation
    # i and set BIC_select = 1 for that model
    model_lowest_BIC <- which(df$BIC[ind] == min(df$BIC[ind]), arr.ind = TRUE)
    ind_BIC <- ind[model_lowest_BIC]
    df$BIC_select[ind_BIC] <- 1

    # select the most parsimonious model with BIC within 2 of the lowest BIC
    # value

    # set BIC_select_2 equal to BIC_select by default
    df$BIC_select_2[ind_BIC] <- 1

    # create variable to track if the while loop should continue
    continue <- 0

    # create variable to track number of classes in smaller model
    c <- 1

    # check if there is a simpler model with BIC within 2 of the min -
    # if there is, change BIC_select_2 to 1 for that model and to 0 for the
    # BIC_select model
    while((continue == 0) & (c < model_lowest_BIC)){
      if(df$BIC[ind[c]] - df$BIC[ind_BIC] < 2){

        df$BIC_select_2[ind[c]] <- 1
        df$BIC_select_2[ind_BIC] <- 0

        continue <- 1

      }else{

        c <- c + 1

      }
    }


    #---------------------------------------------------------------------------
    # NFI

    # if increase in NFI is less than half the increase for the model with one
    # less class, select the model with one less class

    # set up while loop to cycle through models with different numbers of classes
    # until criteria is satisfied (or if not satisifed, pick model with most
    # classes)

    # indicator if while loop should continue or not
    continue <- 0

    # class number to start comparison with
    c <- 3

    while(continue == 0){

      # check if NFI increase for model with c classes is less than half that
      # for the model with c - 1 classes
      if( (df$NFI_diff[ind[c]] / df$NFI_diff[ind[c-1]]) < 0.5){

        # select the c - 1 class model as the best
        df$NFI_select[ind[c-1]] <- 1

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
          df$NFI_select[ind[c]] <- 1
          continue <- 1

        }
      }
    }


    ## apply SEM cutoff of 0.9 for NFI
    # reset indicator if while loop should continue or not
    continue <- 0

    # reset class number to start with
    c <- 1

    while(continue == 0){

      # check if NFI is greater than 0.9
      if(df$NFI[ind[c]] > 0.9){

        # select the c class model as the best
        df$NFI_select_cutoff[ind[c]] <- 1

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
          df$NFI_select_cutoff[ind[c]] <- 1
          continue <- 1

        }
      }
    }
  }

  #----------------------------------------------------------------------------
  # calculate percentage of times each number of classes is chosen by each fit
  # stat

  # create dataframe to store results
  results <- as.data.frame(matrix(NA, nrow = 6, ncol = max_class))
  names(results) <- 1:6
  row.names(results) <- c("AIC", "AIC 2", "BIC", "BIC 2", "NFI", "NFI cutoff")

  # loop through classes calculating percentages
  for(c in 1:max_class){

    # filter to just rows corresponding to models with c classes
    df_c <- df %>%
      filter(Number_of_classes == c)

    # populate results dataframe with percentage of simulations each fit
    # measure selected c classes for
    # AIC
    results[1, c] <- paste0(round((sum(df_c$AIC_select)/1000)*100, 1), "%")
    # AIC 2
    results[2, c] <- paste0(round((sum(df_c$AIC_select_2)/1000)*100, 1), "%")
    # BIC
    results[3, c] <- paste0(round((sum(df_c$BIC_select)/1000)*100, 1), "%")
    # BIC 2
    results[4, c] <- paste0(round((sum(df_c$BIC_select_2)/1000)*100, 1), "%")
    # NFI
    results[5, c] <- paste0(round((sum(df_c$NFI_select)/1000)*100, 1), "%")
    # NFI cutoff
    results[6, c] <- paste0(round((sum(df_c$NFI_select_cutoff)/1000)*100, 1), "%")

  }

  # return dataframe of results
  return(results)

}

## create summaries for each sample size N
summary_500 <- apply_criteria(file_names = paste0("sims_", 500),
                              max_class = 6, N = 500)
summary_5000 <- apply_criteria(file_names = paste0("sims_", 5000),
                               max_class = 6, N = 5000)
summary_10000 <- apply_criteria(file_names = paste0("sims_", 10000),
                                max_class = 6, N = 10000)
summary_30000 <- apply_criteria(file_names = paste0("sims_", 30000),
                                max_class = 6, N = 30000)
summary_100000 <- apply_criteria(file_names = paste0("sims_", 100000),
                                 max_class = 6, N = 100000)

# display the summaries
summary_500
summary_5000
summary_10000
summary_30000
summary_100000
