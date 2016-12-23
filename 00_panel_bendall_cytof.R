##############################################################################
## <<>>

# BioC 3.3
# Created 20 Dec 2016

##############################################################################
Sys.time()
##############################################################################

# Load packages
library(flowCore)
library(limma)

##############################################################################
# Test arguments
##############################################################################

rwd='/Users/gosia/Dropbox/UZH/trajectories_data/bendall_cytof'
path_fcs_file='01_fcs/bendall_sample_a.fcs'
outdir_panel='01_panel'
prefix='bendall_'


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

if(!file.exists(outdir_panel)) 
  dir.create(outdir_panel, recursive = TRUE)


##############################################################################


data <- read.FCS(path_fcs_file)


fcs_colnames <- colnames(data)

fcs_colnames_split1 <- strsplit2(fcs_colnames, "(", fixed = TRUE) 
fcs_colnames_split2 <- strsplit2(fcs_colnames_split1[, 2], ")", fixed = TRUE) 

marker <- fcs_colnames_split1[, 1]
metal <- fcs_colnames_split2[, 1]

metal_for_trajectories <- c("Gd156", "Yb171", "Sm149", "Gd158", "Nd142", "Sm147", "Gd160", "Nd148", "Er168", "In115", "Eu151", "Nd146", "Yb174", "Nd145", "Eu153", "Sm154", "Gd157")

all(metal_for_trajectories %in% metal)


panel <- data.frame(fcs_colnames = fcs_colnames, marker = marker, metal = metal, use_for_trajectories = metal %in% metal_for_trajectories, stringsAsFactors = FALSE)

write.table(panel, file = file.path(outdir_panel, paste0(prefix, "panel.txt")), quote = FALSE, sep = "\t", row.names = FALSE, col.names = TRUE)

























sessionInfo()

##############################################################################
### Done!
##############################################################################