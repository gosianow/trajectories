##############################################################################
## <<>>

# BioC 3.4
# Created 20 Dec 2016

##############################################################################
Sys.time()
##############################################################################

# Load packages
library(ggplot2)
library(reshape2)

##############################################################################
# Test arguments
##############################################################################

rwd='trajectories_data/simulation1'
outdir='02_plot_cell_density'
prefix='sim1_sub1_truth_'
path_trajectory='01_truth/sim1_sub1_truth_trajectory.txt'


##############################################################################
# Read in the arguments
##############################################################################

rm(list = ls())

args <- (commandArgs(trailingOnly = TRUE))
for (i in 1:length(args)) {
  eval(parse(text = args[[i]]))
}

cat(paste0(args, collapse = "\n"), fill = TRUE)

##############################################################################

setwd(rwd)

if(!file.exists(outdir)) 
  dir.create(outdir, recursive = TRUE)


##############################################################################

trajectory <- read.table(path_trajectory, header = TRUE, sep = "\t", as.is = TRUE)


ggp <- ggplot(trajectory, aes(x = trajectory)) +
  geom_density(adjust = 0.5, fill = "blue", alpha = 0.3) + 
  theme_bw()


pdf(file.path(outdir, paste0(prefix, "cell_density_density.pdf")), width = 7, height = 3)
print(ggp)
dev.off()



ggp <- ggplot(trajectory, aes(x = trajectory)) +
  geom_histogram(bins = 200) + 
  theme_bw()


pdf(file.path(outdir, paste0(prefix, "cell_density_hist.pdf")), width = 7, height = 3)
print(ggp)
dev.off()






























sessionInfo()

##############################################################################
### Done!
##############################################################################