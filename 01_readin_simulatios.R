##############################################################################
## <<>>

# BioC 3.3
# Created 20 Dec 2016

##############################################################################
Sys.time()
##############################################################################

# Load packages
library(R.matlab)
library(flowCore)
library(Biobase)
library(ggplot2)
library(reshape2)

##############################################################################
# Test arguments
##############################################################################

rwd='/Users/gosia/Dropbox/UZH/trajectories_data/simulation1'
outdir_r='01_data_r'
outdir_fcs='01_fcs_files'
outdir_panel='01_panel'
outdir_truth='01_truth'
path_data='01_data_mat/albeck2008_Poisson_10000_25000_100.mat'


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

if(!file.exists(outdir_r)) 
  dir.create(outdir_r, recursive = TRUE)

if(!file.exists(outdir_fcs)) 
  dir.create(outdir_fcs, recursive = TRUE)

if(!file.exists(outdir_panel)) 
  dir.create(outdir_panel, recursive = TRUE)

if(!file.exists(outdir_truth)) 
  dir.create(outdir_truth, recursive = TRUE)


##############################################################################


mtarrays <- readMat(path_data, fixNames=TRUE)


time <- mtarrays[["Time"]]
trajectories <- mtarrays[["Trajectories"]]
species_names <- mtarrays[["SpeciesNames"]]


species_names <- unlist(species_names)
names(species_names) <- NULL

time <- as.numeric(time)


trajectories_list <- lapply(1:dim(trajectories)[3], function(i){
  # i = 1
  out <- trajectories[, , i]
  out <- cbind(out, simulation = rep(i, nrow(out)))
  out <- cbind(out, time)
  
})

trajectoriesm <- do.call(rbind, trajectories_list)

colnames(trajectoriesm)[!grepl("simulation|time", colnames(trajectoriesm))] <- species_names


saveRDS(trajectoriesm, file.path(outdir_r, paste0("sim1.rds")))


### Save as FCS file 

# Create an AnnotatedDataFrame needed for flowFrame
trajectories_range <- apply(trajectoriesm, 2, range)

df <- data.frame(name = colnames(trajectoriesm), desc = "none", range = trajectories_range[2, ] - trajectories_range[1, ], minRange = trajectories_range[1, ], maxRange = trajectories_range[2, ], stringsAsFactors = FALSE)
rownames(df) <- colnames(trajectoriesm)
metaData <- data.frame(labelDescription = c("Characters", "Characters", "Numbers", "Numbers", "Numbers"))
  
parameters <- AnnotatedDataFrame(data=df, varMetadata=metaData)


trajectories_fcs <- flowFrame(exprs = trajectoriesm, parameters = parameters, description=list())

write.FCS(trajectories_fcs, filename = file.path(outdir_fcs, paste0("sim1.fcs")))





# ------------------------------------------------------------------------
### Save subsets

cell_sub <- 1:10000

trajectoriesm_sub <- trajectoriesm[cell_sub, ]

saveRDS(trajectoriesm_sub, file.path(outdir_r, paste0("sim1_sub1.rds")))

trajectories_fcs_sub <- flowFrame(exprs = trajectoriesm[cell_sub, ], parameters = parameters, description=list())

write.FCS(trajectories_fcs_sub, filename = file.path(outdir_fcs, paste0("sim1_sub1.fcs")))


# ------------------------------------------------------------------------
### Save the true time trajectory

true_trajectory <- data.frame(trajectory = trajectoriesm_sub[, "time"])

write.table(true_trajectory, file = file.path(outdir_truth, paste0("sim1_sub1_truth_trajectory.txt")), quote = FALSE, sep = "\t", row.names = FALSE, col.names = TRUE)



# ------------------------------------------------------------------------
### Create a panel file

panel <- data.frame(fcs_colnames = df$name, marker = df$name, metal = df$name, use_for_trajectories = !grepl("simulation|time", colnames(trajectoriesm)), stringsAsFactors = FALSE)

write.table(panel, file = file.path(outdir_panel, paste0("sim1_panel.txt")), quote = FALSE, sep = "\t", row.names = FALSE, col.names = TRUE)



# ------------------------------------------------------------------------
### Plot marker distributions


prefix <- "sim1_sub1_"

dfm <- melt(trajectoriesm_sub)

ggp <- ggplot(dfm, aes(x = value)) +
  geom_density(adjust = 1, fill = "black", alpha = 0.3) +
  facet_wrap(~ Var2, scales = "free") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

pdf(file.path(outdir_r, paste0(prefix, "distr_density.pdf")), width = 18, height = 18)
print(ggp)
dev.off()


ggp <- ggplot(dfm, aes(x = value)) +
  geom_histogram(bins = 100) +
  facet_wrap(~ Var2, scales = "free") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

pdf(file.path(outdir_r, paste0(prefix, "distr_histogram.pdf")), width = 18, height = 18)
print(ggp)
dev.off()

















sessionInfo()






##############################################################################
### Done!
##############################################################################