##############################################################################
## <<>>

# BioC 3.3
# Created 21 Dec 2016

##############################################################################
Sys.time()
##############################################################################

# Load packages
library(flowCore)

##############################################################################
# Test arguments
##############################################################################


rwd='/Users/gosia/Dropbox/UZH/trajectories_data/bendall_cytof'
path_fcs_file='01_fcs_files/bendall_sample_a.fcs'
outdir='03_results/wanderlust0'
prefix='bendall_sample_a_wanderlust0_'


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


data <- read.FCS(path_fcs_file)


trajectory <- data.frame(trajectory = exprs(data)[, "wanderlust"])

write.table(trajectory, file = file.path(outdir, paste0(prefix, "trajectory.txt")), quote = FALSE, sep = "\t", row.names = FALSE, col.names = TRUE)






















sessionInfo()

##############################################################################
### Done!
##############################################################################