##############################################################################
## <<>>

# BioC 3.4
# Created 22 Dec 2016

##############################################################################
Sys.time()
##############################################################################

# Load packages
library(flowCore)
library(cytofkit)
library(Rtsne)


##############################################################################
# Test arguments
##############################################################################

rwd='trajectories_data/simulation1'
outdir='02_run_dim_reduction'
prefix='sim1_sub1_norm_tsne_2d_'
path_fcs_file='01_data_norm/sim1_sub1_norm.fcs'
method='tsne'
out_dim=2

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

rand_seed <- 1234

##############################################################################


fcs <- read.FCS(path_fcs_file)


# ---------------------------------------
# Dimension reduction analysis
# ---------------------------------------

### Subsampling
# max_nr_cells=5000
# set.seed(rand_seed)
# keep <- sample(nrow(fcs), max_nr_cells, replace = FALSE)
# e <- exprs(fcs)[keep, ]

e <- exprs(fcs)

### find duplicates
dups <- duplicated(e)  

e <- e[which(!dups), ]


### Remove constant/zero columns

cz_cols <- apply(e, 2, function(x){
  length(table(x)) == 1
})

e <- e[, !cz_cols]


### Run dim reduction
### tSNE does not work for out_dim = 3

if(method == 'tsne'){
  
  set.seed(rand_seed)
  tsne_out <- Rtsne(e, initial_dims = ncol(e), dims = out_dim, check_duplicates = FALSE, pca = TRUE)
  mapped <- tsne_out$Y
  
}else{
  
  mapped <- cytofkit::cytof_dimReduction(e, method = method, out_dim = out_dim)
  
}


dim_names <- paste0("dim", 1:out_dim)

colnames(mapped) <- dim_names


# Save the results

write.table(mapped, file.path(outdir, paste0(prefix, "data.txt")), sep = "\t", quote = FALSE, row.names = FALSE, col.names = TRUE)









sessionInfo()











##############################################################################
### Done!
##############################################################################