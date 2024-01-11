# LCA-fit-indices

Simulation study code to test the performance of normed and non-normed fit indices proposed for latent class analysis in the technical report [Can a Normed Fit Index Assist with Model Selection in Latent Class Analysis with Large Samples? A Preliminary Investigation](https://osf.io/preprints/psyarxiv/3qzvm).

## Description of files

The R script files should be run in the following order.

1.  The file [1 data generation.R](https://github.com/Eva-Ryan/LCA-fit-indices/blob/main/1%20Data%20generation.R) contains code to simulate 1,000 datasets from the LCA data-generating model with parameters described in the below table:

    |                                       |       |          |              Class              |            |                      |
    |:----------:|:----------:|:----------:|:----------:|:----------:|:----------:|
    |                                       |   1   |    2     |                3                |     4      |          5           |
    |                                       | (Low) | (Medium) |             (High)              | (Atypical) | (Slightly Different) |
    | *Latent Class Membership Probability* |  30%  |   25%    |               15%               |    15%     |         15%          |
    |               Indicator               |       |          | *Item-response Probabilities\** |            |                      |
    |                   1                   |  0.8  |   0.9    |               0.8               |    0.8     |         0.7          |
    |                   2                   |  0.8  |   0.9    |               0.8               |    0.2     |         0.7          |
    |                   3                   |  0.2  |   0.9    |               0.8               |    0.8     |         0.7          |
    |                   4                   |  0.2  |   0.9    |               0.8               |    0.2     |         0.7          |
    |                   5                   |  0.2  |   0.1    |               0.8               |    0.8     |         0.3          |
    |                   6                   |  0.2  |   0.1    |               0.8               |    0.2     |         0.3          |

    \*Item response probabilities for "yes" response on the 6 dichotomous indicator items.

2.  The file [2 Fit models in LatentGold.R](https://github.com/Eva-Ryan/LCA-fit-indices/blob/main/2%20Fit%20models%20in%20LatentGold.R) contains code to export the simulated datasets from R to LatentGold, where latent class models with 1-6 classes are fit to each simulated dataset. The following files are created by running this code (where N = sample size, X = simulation number (1-1000)):

    -   Separate .txt files containing each of the simulated datasets called "sims_N\_data_X.txt".

    -   Separate .lgs LatentGold script files containing the LatentGold code for fitting the LCA models to each simulated dataset called "sims_N\_sim_X.lgs".

    -   Separate .lst LatentGold output files containing the LatentGold output from fitting the LCA models to each simulated dataset called "sims_N\_sim_X.lst".

    -   A .csv file called "sims_N\_output.csv" containing all of the LatentGold output for that set of simulations.

    The files [2b Run BLRT in LatentGold - first 500 datasets.R](https://github.com/Eva-Ryan/LCA-fit-indices/blob/main/2b%20Run%20BLRT%20in%20LatentGold%20-%20first%20500%20datasets.R) and [2b Run BLRT in LatentGold - last 500 datasets.R](https://github.com/Eva-Ryan/LCA-fit-indices/blob/main/2b%20Run%20BLRT%20in%20LatentGold%20-%20last%20500%20datasets.R) contain code to run the bootstrapped likelihood ratio test for each of the models fitted to each simulated dataset. As running these tests produces a huge amount of output, the process is split across two scripts/output .csv files. Running these scripts produces similar files to those listed above but including results from the BLRTs.

3.  The file [3 Prepare fit statistics for plotting.R](https://github.com/Eva-Ryan/LCA-fit-indices/blob/main/3%20Prepare%20fit%20statistics%20for%20plotting.R) contains code to extract the required $G^2$ values from the raw LatentGold output and calculate the AIC, BIC, NFI, NNFI, and RMSEA values for each fitted model. The calculated fit statistics for different sample sizes N are then outputted in .csv files called "sims_N\_output_summary.csv" . Similarly, the file [3b Prepare BLRT for summarising.R](https://github.com/Eva-Ryan/LCA-fit-indices/blob/main/3b%20Prepare%20BLRT%20for%20summarising.R) contains code to extract BLRT p-values from the raw LatentGold output. These values are outputted in .csv files called "sims_N\_\_BLRT_summary.csv".

4.  The file [4 Fit stats plots.R](https://github.com/Eva-Ryan/LCA-fit-indices/blob/main/4%20Fit%20stats%20plots.R) contains code to create individual plots for each fit index (except the RMSEA), and the below summary plot of average AIC, BIC, and NFI values for LCA models with 1-6 classes across the different sample sizes considered in the simulation study:

    ![](https://github.com/Eva-Ryan/LCA-fit-indices/blob/main/Plots/All_plots.jpg)

<!-- -->

5.  The file [5 Fit stats criteria class selection summary.R](https://github.com/Eva-Ryan/LCA-fit-indices/blob/main/5%20Fit%20stats%20criteria%20class%20selection%20summary.R) contains code to apply the various AIC, BIC, and NFI model selection criteria to the simulations and calculate the percentage of simulations for which each criteria selects each number of classes as the best LCA model fit.

6.  The folder [Final output summaries](https://github.com/Eva-Ryan/LCA-fit-indices/tree/main/Final%20output%20summaries) contains the .csv files of fit statistics created by running the code in the files [3 Prepare fit statistics for plotting.R](https://github.com/Eva-Ryan/LCA-fit-indices/blob/main/3%20Prepare%20fit%20statistics%20for%20plotting.R) and [3b Prepare BLRT for summarising.R](https://github.com/Eva-Ryan/LCA-fit-indices/blob/main/3b%20Prepare%20BLRT%20for%20summarising.R).

7.  The folder [Plots](https://github.com/Eva-Ryan/LCA-fit-indices/tree/main/Plots) contains the plots created by running the code in the file [4 Fit stats plots.R](https://github.com/Eva-Ryan/LCA-fit-indices/blob/main/4%20Fit%20stats%20plots.R).

**Note:** When running the simulations, the working directory should also contain a folder called "Simulations" with subfolders to store the LatentGold files and output (created when running the file [2 Fit models in LatentGold.R](https://github.com/Eva-Ryan/LCA-fit-indices/blob/main/2%20Fit%20models%20in%20LatentGold.R)) for each set of simulations.
