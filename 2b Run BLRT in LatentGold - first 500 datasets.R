################################################################################
# Run this script to export the datasets generated using the
# "1 Data generation.R" script to LatentGOLD, fit LCA models with 1-6 classes,
# and run the BLRT for these models.
# See page 29,96/97 of the LG Syntax User Guide.
################################################################################

## Specify LatentGOLD folder
LG <- 'C:/Users/eva.ryan/Documents/LatentGOLD6.0//lg60.exe'

# get current working directory
directory <- getwd()

## function to create LatentGOLD syntax to fit LCA models to generated data AND
## calculate BLRT
makeNewSyntaxBLRT = function(in_file, out_file_BLRT){
  # Input: in_file = .txt file of the dataset the LCA models are to be fitted to
  # Outputs: out_file_VLRT = combined LatentGOLD output file with results of
  #                          the BLRT for each model fitted in the simulation

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
      seed=0 sets=16 replicates=500 tolerance=1e-008
      LLdiff;
 missing  includeall;
 output
 append = '",out_file_BLRT,"' ;
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

## Fit the models and run BLRT

# set naming convention for output files - use sample size N (defined in "1 Data generation.R")
file_names <- paste0("sims_", N)

# set folder to save output
setwd(paste0(directory, '/Simulations/', file_names, "/BLRT"))

# set output file name
out_file_BLRT <- paste0(file_names, "_output_BLRT.csv")

# time operation
tic("BLRT runtime")

# cycle through the r simulated datasets, fitting models and running BLRT
for(i in 1:(r/2)){

  # set unique names for each file of simulation i
  ID <- i
  in_file <- paste0(file_names, "_data_", ID, ".txt")
  modelfile_BLRT <- paste0(file_names, "_sim_", ID, "_BLRT.lgs")

  # save simulated dataset #i as a .txt file
  write.table(sims$datasets[[i]],
              in_file,
              na = ".",
              sep = " ",
              row.names = FALSE,
              quote = FALSE)

  # create LG Syntax file to run BLRT on the models fitted to
  # dataset i
  write.table(makeNewSyntaxBLRT(in_file,
                            out_file_BLRT),
              modelfile_BLRT,
              row.names = FALSE,
              quote = FALSE,
              col.names = FALSE)

  # execute the syntax file in LatendGold
  shell(paste(LG, modelfile_BLRT, "/b"))

}

# finish timing
toc()
