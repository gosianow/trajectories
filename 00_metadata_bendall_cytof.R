##############################################################################
## <<>>

# BioC 3.3
# Created 20 Dec 2016

##############################################################################
Sys.time()
##############################################################################

# Load packages

##############################################################################
# Test arguments
##############################################################################

rwd='/Users/gosia/Dropbox/UZH/trajectories_data/bendall_cytof'
path_fcs='01_fcs_files_orig'
outdir_metadata='01_metadata'
outdir_fcs='01_fcs_files'
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

if(!file.exists(outdir_metadata)) 
  dir.create(outdir_metadata, recursive = TRUE)

if(!file.exists(outdir_fcs)) 
  dir.create(outdir_fcs, recursive = TRUE)

##############################################################################


fcs_files_all <- list.files(path_fcs, pattern = ".fcs")
fcs_files_all

### Keep only the A, B, C and D basal samples

keep <- grepl("Sample_A_basal|Sample_B_basal|Sample_C_basal|Sample_D_basal", fcs_files_all)

fcs_files_keep <- fcs_files_all[keep]

short_names <- gsub("et_al_Cell_|_basal", "", fcs_files_keep)

short_names <- tolower(short_names)


### Create a metadata file

metadata <- data.frame(file_name = fcs_files_keep, short_name = short_names, stringsAsFactors = FALSE)

write.table(metadata, file = file.path(outdir_metadata, paste0(prefix, "metadata.txt")), quote = FALSE, sep = "\t", row.names = FALSE, col.names = TRUE)



### Copy FCS files to a new directory and with new names

for(i in 1:nrow(metadata)){
  file.copy(from = file.path(path_fcs, metadata[i, "file_name"]), to = file.path(outdir_fcs, metadata[i, "short_name"]), overwrite = TRUE)
}























sessionInfo()

##############################################################################
### Done!
##############################################################################