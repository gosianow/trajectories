##############################################################################
## <<>>

# BioC 3.4
# Created 23 Dec 2016

##############################################################################
Sys.time()
##############################################################################

# Load packages
library(scatterplot3d)
library(RColorBrewer)

##############################################################################
# Test arguments
##############################################################################

rwd='trajectories_data/simulation1'
outdir='02_plot_dim_reduction'
prefix='sim1_sub1_norm_truth_pca_3d_'
path_dim_reduction='02_run_dim_reduction/sim1_sub1_norm_pca_3d_data.txt'
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
trajectory <- trajectory$trajectory


### Create colors 
color_palette <- colorRampPalette(rev(brewer.pal(n = 11, name = "Spectral")))(101)

trajectory_norm <- round((trajectory - min(trajectory)) /(max(trajectory) - min(trajectory)) * 100 + 1)

trajectory_colors <- color_palette[trajectory_norm]


df <- cbind(data, trajectory, trajectory_colors)


### Plotting

pdf(file.path(outdir, paste0(prefix, "plot.pdf")), width = 9, height = 7)

scatterplot3d(x = df$dim1, y = df$dim2, z = df$dm3, color = df$trajectory_colors, pch = 19, cex.symbols = 0.5, xlab="dim1", ylab="dim2", zlab="dim3")

dev.off()










sessionInfo()











##############################################################################
### Done!
##############################################################################