##############################################################################
## <<>>

# BioC 3.4
# Created 22 Dec 2016

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
outdir='02_plot_dim_reduction'
prefix='sim1_sub1_norm_truth_pca_2d_'
path_dim_reduction='02_run_dim_reduction/sim1_sub1_norm_pca_2d_data.txt'
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


data <- read.table(path_dim_reduction, header = TRUE, sep = "\t", as.is = TRUE)

trajectory <- read.table(path_trajectory, header = TRUE, sep = "\t", as.is = TRUE)



### Plotting

ggdf <- cbind(data, trajectory)


ggp <- ggplot(ggdf,  aes(x = dim1, y = dim2, color = trajectory)) +
  geom_point() +
  labs(x = "dim1", y = "dim2") + 
  theme_bw() +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) +
  scale_colour_distiller(palette = "Spectral")


pdf(file.path(outdir, paste0(prefix, "plot.pdf")), width = 9, height = 7)
print(ggp)
dev.off()








sessionInfo()











##############################################################################
### Done!
##############################################################################