##############################################################################
## <<>>

# BioC 3.3
# Created 22 Dec 2016

##############################################################################
Sys.time()
##############################################################################

# Load packages
library(flowCore)
library(cytofkit)
library(igraph)

##############################################################################
# Test arguments
##############################################################################

rwd='/Users/gosia/Dropbox/UZH/trajectories_data/simulation1'
outdir='02_run_dim_reduction'
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

dr_tsne <- cytofkit::cytof_dimReduction(e, method="tsne", tsneSeed = rand_seed)

dr_diffusion <- cytofkit::cytof_dimReduction(e, method="diffusionmap")

dr_pca <- cytofkit::cytof_dimReduction(e, method="pca")



### MST and isomap take too much time...

# MST

# adjacency <- dist(e, method = "euclidean")
# 
# fullGraph <- igraph::graph.adjacency(as.matrix(adjacency), mode = "undirected", weighted = TRUE)
# 
# MST_graph <- igraph::minimum.spanning.tree(fullGraph)
# 
# MST_l <- igraph::layout.kamada.kawai(MST_graph) 
# 
# dr_mst <- MST_l
# 
# 
# dr_isomap <- cytofkit::cytof_dimReduction(e, method="isomap")






# Save the results

colnames(dr_tsne) <- c("dim1", "dim2")

write.table(dr_tsne, file.path(outdir, paste0(prefix, "tsne.txt")), sep = "\t", quote = FALSE, row.names = FALSE, col.names = TRUE)


colnames(dr_diffusion) <- c("dim1", "dim2")

write.table(dr_diffusion, file.path(outdir, paste0(prefix, "diffusion.txt")), sep = "\t", quote = FALSE, row.names = FALSE, col.names = TRUE)


colnames(dr_pca) <- c("dim1", "dim2")

write.table(dr_pca, file.path(outdir, paste0(prefix, "pca.txt")), sep = "\t", quote = FALSE, row.names = FALSE, col.names = TRUE)




# colnames(dr_isomap) <- c("dim1", "dim2")
# 
# write.table(dr_isomap, file.path(outdir, paste0(prefix, "isomap.txt")), sep = "\t", quote = FALSE, row.names = FALSE, col.names = TRUE)
# 
# 
# colnames(dr_mst) <- c("dim1", "dim2")
# 
# write.table(dr_mst, file.path(outdir, paste0(prefix, "mst.txt")), sep = "\t", quote = FALSE, row.names = FALSE, col.names = TRUE)







sessionInfo()











##############################################################################
### Done!
##############################################################################