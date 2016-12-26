##############################################################################
## <<>>

# BioC 3.4
# Created 23 Dec 2016

##############################################################################
Sys.time()
##############################################################################

# Load packages
library(ggplot2)
library(reshape2)
library(flowCore)
library(RColorBrewer)

##############################################################################
# Test arguments
##############################################################################

rwd='trajectories_data/simulation1'
outdir='02_plot_markers_truth'
prefix='sim1_sub1_norm_truth_'
path_trajectory='01_truth/sim1_sub1_truth_trajectory.txt'
path_fcs_file='01_fcs_norm/sim1_sub1_norm.fcs'

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

color_palette <- colorRampPalette(rev(brewer.pal(11, 'RdYlBu')))

##############################################################################

trajectory <- read.table(path_trajectory, header = TRUE, sep = "\t", as.is = TRUE)

fcs <- read.FCS(path_fcs_file)


### Plot marker expression over time

df <- data.frame(exprs(fcs), trajectory)

dfm <- melt(df, id.vars = "trajectory", value.name = "expression", variable.name = "fcs_colnames")


ggp <- ggplot(dfm, aes(x = trajectory, y = expression)) +
  geom_bin2d(bins = 50) +
  facet_wrap(~ fcs_colnames, scales = "free") +
  theme_bw() +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) +
  scale_fill_gradientn(colours = color_palette(100))


pdf(file.path(outdir, paste0(prefix, "markers_density.pdf")), width = 18, height = 18)
print(ggp)
dev.off()




ggp <- ggplot(dfm, aes(x = trajectory, y = expression)) +
  geom_smooth() +
  facet_wrap(~ fcs_colnames, scales = "free") +
  theme_bw() +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())


pdf(file.path(outdir, paste0(prefix, "markers_smooth.pdf")), width = 18, height = 18)
print(ggp)
dev.off()

























sessionInfo()

##############################################################################
### Done!
##############################################################################