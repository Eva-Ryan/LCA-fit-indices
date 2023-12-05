################################################################################
# Use this script to generate datasets for the simulation study prior to running
# the code in "2 Fit models in LatentGOLD.R" to fit LCA models to the generated
# datasets.
################################################################################

# load packages
library(beepr)

## function to generate data 

LCA_sim <- function(N, r, rhos, gammas){
  # Inputs: N = sample size for each generated dataset
  #         r = replications - number of datasets to generate 
  #         rhos = matrix of item response probabilities
  #         gammas = vector of class membership probabilities
  # Outputs: a list ret containing the values for all input parameters, an
  #          array datasets containing the generated datasets, and a vector
  #          seeds containing the seeds used to ensure the data generation
  #          is reproducible
  
  # generate r random seeds
  set.seed(123)
  r_seeds <- sample.int(1000000000, size = r, replace = FALSE)
  
  # set number of classes and number of items
  num_classes <- ncol(rhos)
  num_items <- nrow(rhos)
  
  # simulate r datasets and store in the list datasets_list
  datasets_list <- list()
  
  for(i in 1:r){
    
    # initialise data matrix 
    df <- matrix(NA, nrow = N, ncol = (num_items + 1)) # extra column for class
    
    # assign classes and populate first column of data matrix with class number
    set.seed(r_seeds[i])
    df[,1] <- sample(1:num_classes, N, replace = TRUE, prob = gammas)
    
    # simulate class dependent item responses k for class j
    for(j in 1:num_classes){
      
      # create vector of indices for the cases which are in class j
      ind <- which(df[,1] == j, arr.ind = TRUE)
      
      # create an empty matrix to store the item responses for the class j cases
      sim.vals <- matrix(NA, length(ind), num_items)
      
      # loop through the k items and generate responses
      for(k in 1:num_items){
        
        # set a new seed for each item/class/replication
        set.seed( round(r_seeds[i]/(j * k * 1000), 0) )
        sim.vals[,k] <- sample(c(1,0), length(ind), replace = TRUE,
                               prob = c(rhos[k,j], 1 - rhos[k,j]))
      }
      
      # populate the rows of the data matrix that correspond to class j with 
      # the generated item responses
      df[ind, 2:(num_items+1)] <- sim.vals
      
    }
    
    # save as dataframe, name columns, and convert column entries to type factor
    df <- as.data.frame(df)
    names(df) <- c("Class", paste0("V", 1:num_items))
    df[] <- lapply(df, factor)
    
    # save generated dataset in list
    datasets_list[[i]] <- df
  }
  
  # create list of outputs
  ret <- list()
  ret$datasets <- datasets_list
  ret$rhos <- rhos
  ret$gammas <- gammas
  ret$N <- N
  ret$r <- r
  ret$seeds <- r_seeds
  
  return(ret)
}

## set input parameters for LCA_sim

# sample size
N = 30000

# number of replications
r = 1000

# create matrix of item response probabilities
rhos <- matrix(.8, nrow = 6, ncol = 5)
rhos[3:6,1] <- .2
rhos[1:4,2] <- .9
rhos[5:6,2] <- .1
rhos[c(2,4,6),4] <- .2
rhos[1:4,5] <- .7
rhos[5:6,5] <- .3


# create vector of class membership probabilities
gammas <- c(0.3, 0.25, 0.15, 0.15, 0.15)

## simulate data sets

# time data generation
library(tictoc)
tic("Data generation runtime")

# generate data
sims <- LCA_sim(N, r, rhos, gammas)

# finish timing
toc()

# make a noise when finished
beep(3)
