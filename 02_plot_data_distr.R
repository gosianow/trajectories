##############################################################################
## <<>>

# BioC 3.3
# Created 22 Dec 2016

##############################################################################
Sys.time()
##############################################################################

# Load packages
library(ggplot2)
library(reshape2)
library(flowCore)

##############################################################################
# Test arguments
##############################################################################

rwd='/Users/gosia/Dropbox/UZH/trajectories_data/simulation1'
outdir='02_plot_data_distr'
prefix='sim1_sub1_norm_'
path_fcs_file='01_data_norm/sim1_sub1_norm.fcs'

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


fcs <- read.FCS(path_fcs_file)


### Plot marker distributions

df <- data.frame(exprs(fcs))

dfm <- melt(df, value.name = "expression", variable.name = "fcs_colnames")


ggp <- ggplot(dfm, aes(x = expression)) +
  geom_density(adjust = 1, fill = "black", alpha = 0.3) +
  facet_wrap(~ fcs_colnames, scales = "free") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

pdf(file.path(outdir, paste0(prefix, "distr_density.pdf")), width = 18, height = 18)
print(ggp)
dev.off()


ggp <- ggplot(dfm, aes(x = expression)) +
  geom_histogram(bins = 100) +
  facet_wrap(~ fcs_colnames, scales = "free") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

pdf(file.path(outdir, paste0(prefix, "distr_histogram.pdf")), width = 18, height = 18)
print(ggp)
dev.off()








sessionInfo()











##############################################################################
### Done!
##############################################################################