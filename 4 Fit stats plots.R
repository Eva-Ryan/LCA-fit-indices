################################################################################
# Code to create plots of mean values and 95% coverage intervals for AIC/BIC/NFI
# across models with different numbers of classes. Uses the summary output
# files created in "3 Prepare fit statistics for plotting.R".
################################################################################

## load packages
library(tidyverse)
library(gridExtra)
library(grid)
library(ggpubr)

# get current working directory
directory <- getwd()

## function to calculate means and 95% coverage intervals for each stat and
# construct plots
plot_means_CI <- function(file_names, max_class, N){
  # Inputs: file_names = naming convention for the folders/files relating to the
  #                      simulation of interest
  #         max_class = the maximum number of classes in the models fitted to
  #                     the simulated datasets
  #         N = sample size for the simulations
  # Output: plot_list = list containing the AIC/BIC/NFI plots

  # set working directory to where fit index summaries are saved
  setwd(paste0(directory, "/Final output summaries"))

  # read in summary of simulation models fit stats
  df <- read_csv(paste0(file_names, "_output_summary.csv"))

  # create empty dataframes to populate with means and confidence intervals for
  # each fit stat
  # AIC
  AICs <- as.data.frame(matrix(NA, nrow = max_class, ncol =  4))
  names(AICs) <- c("classes", "means", "lower", "upper")
  AICs$classes <- 1:max_class
  # BIC
  BICs <- as.data.frame(matrix(NA, nrow = max_class, ncol =  4))
  names(BICs) <- c("classes", "means", "lower", "upper")
  BICs$classes <- 1:max_class
  # NFI
  NFIs <- as.data.frame(matrix(NA, nrow = max_class, ncol =  4))
  names(NFIs) <- c("classes", "means", "lower", "upper")
  NFIs$classes <- 1:max_class
  # NNFI
  NNFIs <- as.data.frame(matrix(NA, nrow = max_class, ncol =  4))
  names(NNFIs) <- c("classes", "means", "lower", "upper")
  NNFIs$classes <- 1:max_class

  # cycle through different number of classes
  for(c in 1:max_class){

    # filter out just models with c classes
    df_c <- df %>%
      filter(Number_of_classes == c)

    # calculate mean and 95% coverage intervals
    # AIC
    AICs$means[c] <- mean(df_c$AIC)
    AICs$lower[c] <- df_c$AIC[order(df_c$AIC)][25]
    AICs$upper[c] <- df_c$AIC[order(df_c$AIC)][976]
    # BIC
    BICs$means[c] <- mean(df_c$BIC)
    BICs$lower[c] <- df_c$BIC[order(df_c$BIC)][25]
    BICs$upper[c] <- df_c$BIC[order(df_c$BIC)][976]
    # NFI
    NFIs$means[c] <- mean(df_c$NFI)
    NFIs$lower[c] <- df_c$NFI[order(df_c$NFI)][25]
    NFIs$upper[c] <- df_c$NFI[order(df_c$NFI)][976]
    # NNFI
    NNFIs$means[c] <- mean(df_c$NNFI)
    NNFIs$lower[c] <- df_c$NNFI[order(df_c$NNFI)][25]
    NNFIs$upper[c] <- df_c$NNFI[order(df_c$NNFI)][976]

  }

  ## create plots
  # AIC plot
  aic_plot <- ggplot(AICs, aes(x = classes, y = means)) +
    geom_line(linewidth = 1) +
    geom_errorbar(linewidth = 1, width = .75, aes(ymin = lower, ymax = upper),
                  colour = "red") +
    geom_point(shape = 21, size = 2, fill = "white") +
    theme_light() +
    xlab("") + ylab("") +
    ggtitle("AIC") +
    theme(plot.title = element_text(hjust = 0.5)) +
    scale_x_continuous(breaks = c(1:max_class))

  # BIC plot
  bic_plot <- ggplot(BICs, aes(x = classes, y = means)) +
    geom_line(linewidth = 1) +
    geom_errorbar(linewidth = 1, width = .75, aes(ymin = lower, ymax = upper),
                  colour = "red") +
    geom_point(shape = 21, size = 2, fill = "white") +
    theme_light() +
    xlab("") + ylab("") +
    ggtitle("BIC") +
    theme(plot.title = element_text(hjust = 0.5)) +
    scale_x_continuous(breaks = c(1:max_class))

  # NFI plot
  nfi_plot <- ggplot(NFIs, aes(x = classes, y = means)) +
    geom_line(linewidth = 1) +
    geom_errorbar(linewidth = 1, width = .75, aes(ymin = lower, ymax = upper),
                  colour = "red") +
    geom_point(shape = 21, size = 2, fill = "white") +
    theme_light() +
    xlab("") + ylab("") +
    ggtitle("NFI") +
    theme(plot.title = element_text(hjust = 0.5)) +
    scale_x_continuous(breaks = c(1:max_class))

  # NNFI plot
  nnfi_plot <- ggplot(NNFIs, aes(x = classes, y = means)) +
    geom_line(linewidth = 1) +
    geom_errorbar(linewidth = 1, width = .75, aes(ymin = lower, ymax = upper),
                  colour = "red") +
    geom_point(shape = 21, size = 2, fill = "white") +
    theme_light() +
    xlab("") + ylab("") +
    ggtitle("NNFI") +
    theme(plot.title = element_text(hjust = 0.5)) +
    scale_x_continuous(breaks = c(1:max_class))

  ## save plots individually

  # set working directory to plots folder
  setwd(paste0(directory, "/Plots"))

  # AIC
  ggsave(
    filename = paste0(file_names, "_AIC_plot.jpg"),
    plot = aic_plot,
    units = "in",
    width = 7,
    height = 5,
    dpi = 600
  )
  # BIC
  ggsave(
    filename = paste0(file_names, "_BIC_plot.jpg"),
    plot = bic_plot,
    units = "in",
    width = 7,
    height = 5,
    dpi = 600
  )
  # NFI
  ggsave(
    filename = paste0(file_names, "_NFI_plot.jpg"),
    plot = nfi_plot,
    units = "in",
    width = 7,
    height = 5,
    dpi = 600
  )

  # NNFI
  ggsave(
    filename = paste0(file_names, "_NNFI_plot.jpg"),
    plot = nnfi_plot,
    units = "in",
    width = 7,
    height = 5,
    dpi = 600
  )

  # return list of plots - AIC/BIC/NFI only
  plot_list <- list()
  plot_list[[1]] <- aic_plot
  plot_list[[2]] <- bic_plot
  plot_list[[3]] <- nfi_plot

  return(plot_list)

}

## create individual plots for different sample sizes
plots_500 <- plot_means_CI(file_names = paste0("sims_", 500),
                           max_class = 6,
                           N = 500)
plots_5000 <- plot_means_CI(file_names = paste0("sims_", 5000),
                            max_class = 6,
                            N = 5000)
plots_10000 <- plot_means_CI(file_names = paste0("sims_", 10000),
                             max_class = 6,
                             N = 10000)
plots_30000 <- plot_means_CI(file_names = paste0("sims_", 30000),
                             max_class = 6,
                             N = 30000)
plots_100000 <- plot_means_CI(file_names = paste0("sims_", 100000),
                              max_class = 6,
                              N = 100000)

## combine all plots together into one figure
plot_grid <- grid.arrange(
  arrangeGrob(grobs = plots_500, left = "N = 500", ncol = 3, nrow = 1),
  arrangeGrob(grobs = plots_5000, left = "N = 5,000", ncol = 3, nrow = 1),
  arrangeGrob(grobs = plots_10000, left = "N = 10,000", ncol = 3, nrow = 1),
  arrangeGrob(grobs = plots_30000, left = "N = 30,000", ncol = 3, nrow = 1),
  arrangeGrob(grobs = plots_100000, left = "N = 100,000", ncol = 3, nrow = 1),
  ncol = 1, nrow = 5,
  top = text_grob("Fit Criteria Mean Values by Number of Classes, with 95% Coverage Bars",
                  size = 15))

# save the combined plot
ggsave(
  filename = "All_plots.jpg",
  plot = plot_grid,
  units = "in",
  width = 10,
  height = 15,
  dpi = 1000
)
