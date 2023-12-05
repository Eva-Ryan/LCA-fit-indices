################################################################################
# Run this script to export the datasets generated using the
# "1 Data generation.R" script to LatentGOLD, fit LCA models with 1-6 classes,
# and calculate the standard measures of model fit.
################################################################################

# load packages
library(beepr)

# get current working directory
directory <- getwd()

## Specify LatentGOLD folder
LG <- 'C:/Users/eva.ryan/Documents/LatentGOLD6.0//lg60.exe'

## function to create LatentGOLD syntax to fit LCA models to generated data
makeNewSyntax = function(in_file, out_file){
  # Input: in_file = .txt file of the dataset the LCA models are to be fitted to
  # Outputs: out_file = combined LatentGOLD output file to append details of
  #          the fitted models, standard fit measures etc. for the LCA models
  #          with 1 - 6 classes for each dataset in the simulation study

  paste("//LG6.0//
version = 6.0
infile '",in_file,"'
model
options
	 algorithm
 tolerance=1e-008 emtolerance=0.01 emiterations=250 nriterations=50;
 startvalues
 seed=123 sets=100 tolerance=1e-005 iterations=300;
 bayes
 categorical=1 variances=1 latent=1 poisson=1;
 montecarlo
      seed=0 sets=0 replicates=500 tolerance=1e-008;
 missing  includeall;
 output profile
 append = '",out_file,"' ;
 variables
  dependent V1 nominal 2, V2 nominal 2, V3 nominal 2, V4 nominal 2,
    V5 nominal 2, V6 nominal 2 ;
  latent
   Cluster nominal 1:6 ;
equations
	Cluster <- 1;
	V1 <- 1 + Cluster;
	V2 <- 1 + Cluster;
	V3 <- 1 + Cluster;
	V4 <- 1 + Cluster;
	V5 <- 1 + Cluster;
	V6 <- 1 + Cluster;

end model
",sep="")

}

## Fit the models

# set naming convention for output files - use sample size N (defined in "1 Data generation.R")
file_names <- paste0("sims_", N)

# set folder to save output
setwd(paste0(directory, '/Simulations/', file_names))

# set output file name
out_file <- paste0(file_names, "_output.csv")

# time operation
tic("Simulations runtime")

# cycle through the r simulated datasets and fit models to each
for(i in 1:r){

  # set unique names for each file of simulation i
  ID <- i
  in_file <- paste0(file_names, "_data_", ID, ".txt")
  modelfile <- paste0(file_names, "_sim_", ID, ".lgs")

  # save simulated dataset #i as a .txt file
  write.table(sims$datasets[[i]],
              in_file,
              na = ".",
              sep = " ",
              row.names = FALSE,
              quote = FALSE)

  # create LG Syntax file to fit models to simulated dataset i
  write.table(makeNewSyntax(in_file,
                            out_file),
              modelfile,
              row.names = FALSE,
              quote = FALSE,
              col.names = FALSE)

  # execute the syntax file in LatendGold
  shell(paste(LG, modelfile, "/b"))#,"/h"))

}

# finish timing
toc()

# make a noise when finished
beep(3)
