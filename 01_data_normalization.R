##############################################################################
## <<>>

# BioC 3.4
# Created 22 Dec 2016

##############################################################################
Sys.time()
##############################################################################

# Load packages
library(flowCore)

##############################################################################
# Test arguments
##############################################################################

rwd='trajectories_data/simulation1'
outdir='01_data_norm'
prefix='sim1_sub1_'
path_fcs_file='01_fcs_files/sim1_sub1.fcs'
path_panel='01_panel/sim1_panel.txt'


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


panel <- read.table(path_panel, header = TRUE, sep = "\t", as.is = TRUE)

fcs <- read.FCS(path_fcs_file)


### Keep only those samples that are TRUE in panel$use_for_trajectories

keep <- colnames(fcs) %in% panel$fcs_colnames[panel$use_for_trajectories]

fcs_sub <- fcs[, keep]


### Arcsineh normalization

exprs(fcs_sub) <- asinh( exprs(fcs_sub) / 5 )


### Save the results

write.FCS(fcs_sub, filename = file.path(outdir, paste0(prefix, "norm.fcs")))


saveRDS(exprs(fcs_sub), file.path(outdir, paste0(prefix, "norm.rds")))





sessionInfo()











##############################################################################
### Done!
##############################################################################