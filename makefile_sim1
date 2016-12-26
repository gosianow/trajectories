### Define the version of R and the path to software
R := R_LIBS_SITE=/home/gosia/programs/Rlibraries/BioC34/:/home/Shared/Rlib/release-3.4-lib/ /usr/local/R/R-3.3.1/bin/R CMD BATCH --no-restore --no-save
### cd /home/Shared/data/cytof/trajectories_data
RWD_MAIN := .
RCODE := $(RWD_MAIN)/trajectories_code
RWD := $(RWD_MAIN)/simulation1
ROUT := $(RWD)/Rout

dir_data_mat := $(RWD)/01_data_mat
dir_fcs := $(RWD)/01_fcs
dir_panel := $(RWD)/01_panel
dir_truth := $(RWD)/01_truth
dir_fcs_norm := $(RWD)/01_fcs_norm
dir_plot_cell_density_truth := $(RWD)/02_plot_cell_density_truth
dir_plot_data_distr := $(RWD)/02_plot_data_distr
dir_run_dim_reduction := $(RWD)/02_run_dim_reduction
dir_plot_dim_reduction_truth := $(RWD)/02_plot_dim_reduction_truth
dir_plot_markers_truth := $(RWD)/02_plot_markers_truth

file_mat := albeck2008_Poisson_10000_25000_100.mat

### Define a list of FCS files that should be analyzed
FCS := sim1_sub1
DATA := sim1

## Define the default rule (makefiles are usually written so that the first target is for compiling the entire program)
.PHONY: all
all: mkdir_rout $(foreach i,$(FCS),$(dir_fcs_norm)/$(i)_norm.rds) plot_cell_density_truth_goal plot_data_distr_goal plot_dim_reduction_truth_goal plot_markers_truth_goal


### Make sure no intermediate files are deleted
.SECONDARY:

.PHONY: mkdir_rout
mkdir_rout:
	mkdir -p $(ROUT)

##########################################################################################################
### Data extracting
##########################################################################################################

# ----------------------------------------------------------------------
### Extract FCS files, panel and true trajectory from the .mat file
# ----------------------------------------------------------------------

$(dir_fcs)/$(FCS).fcs $(dir_panel)/$(DATA)_panel.txt $(dir_truth)/$(FCS)_truth_trajectory.txt: $(dir_data_mat)/$(file_mat) $(RCODE)/00_readin_simulatios.R
	$R "--args rwd='$(RWD_MAIN)' outdir_fcs='$(dir_fcs)' outdir_panel='$(dir_panel)' outdir_truth='$(dir_truth)' path_data='$(dir_data_mat)/$(file_mat)'" $(RCODE)/00_readin_simulatios.R $(ROUT)/00_readin_simulatios.Rout


##########################################################################################################
### Data preparation
##########################################################################################################

# ----------------------------------------------------------------------
### Data normalization - arcsineh
# ----------------------------------------------------------------------

define data_normalization_rule
$(dir_fcs_norm)/$(1)_norm.fcs $(dir_fcs_norm)/$(1)_norm.rds: $(dir_fcs)/$(1).fcs $(dir_panel)/$(DATA)_panel.txt $(RCODE)/01_data_normalization.R
	$R "--args rwd='$(RWD_MAIN)' outdir='$(dir_fcs_norm)' prefix='$(1)_' path_fcs_file='$(dir_fcs)/$(1).fcs' path_panel='$(dir_panel)/$(DATA)_panel.txt'" $(RCODE)/01_data_normalization.R $(ROUT)/01_data_normalization.Rout
endef
$(foreach i,$(FCS),$(eval $(call data_normalization_rule,$(i))))


# ----------------------------------------------------------------------
### Plot data distributions
# ----------------------------------------------------------------------


.PHONY: plot_data_distr_goal
plot_data_distr_goal: $(foreach i,$(FCS),$(dir_plot_data_distr)/$(i)_norm_distr_density.pdf)

define plot_data_distr_rule
$(dir_plot_data_distr)/$(1)_norm_distr_density.pdf: $(dir_fcs_norm)/$(1)_norm.fcs $(RCODE)/02_plot_data_distr.R
	$R "--args rwd='$(RWD_MAIN)' outdir='$(dir_plot_data_distr)' prefix='$(1)_norm_' path_fcs_file='$(dir_fcs_norm)/$(1)_norm.fcs'" $(RCODE)/02_plot_data_distr.R $(ROUT)/02_plot_data_distr.Rout
endef
$(foreach i,$(FCS),$(eval $(call plot_data_distr_rule,$(i))))


# ----------------------------------------------------------------------
### Run dimension reduction
# ----------------------------------------------------------------------

DIM_RED_METHODS := pca tsne diffusion

### 2D
define run_dim_reduction_rule
$(dir_run_dim_reduction)/$(1)_norm_$(2)_2d_data.txt: $(dir_fcs_norm)/$(1)_norm.fcs $(RCODE)/02_run_dim_reduction.R
	$R "--args rwd='$(RWD_MAIN)' outdir='$(dir_run_dim_reduction)' prefix='$(1)_norm_$(2)_2d_' path_fcs_file='$(dir_fcs_norm)/$(1)_norm.fcs' method='$(2)' out_dim=2" $(RCODE)/02_run_dim_reduction.R $(ROUT)/02_run_dim_reduction.Rout
endef
$(foreach i,$(FCS),$(foreach j,$(DIM_RED_METHODS),$(eval $(call run_dim_reduction_rule,$(i),$(j)))))

### 3D
define run_dim_reduction_rule
$(dir_run_dim_reduction)/$(1)_norm_$(2)_3d_data.txt: $(dir_fcs_norm)/$(1)_norm.fcs $(RCODE)/02_run_dim_reduction.R
	$R "--args rwd='$(RWD_MAIN)' outdir='$(dir_run_dim_reduction)' prefix='$(1)_norm_$(2)_3d_' path_fcs_file='$(dir_fcs_norm)/$(1)_norm.fcs' method='$(2)' out_dim=3" $(RCODE)/02_run_dim_reduction.R $(ROUT)/02_run_dim_reduction.Rout
endef
$(foreach i,$(FCS),$(foreach j,$(DIM_RED_METHODS),$(eval $(call run_dim_reduction_rule,$(i),$(j)))))


##########################################################################################################
### Plots for the true trajectory
##########################################################################################################

METHOD := truth

# ----------------------------------------------------------------------
### Plot cell density over time for the truth trajectory
# ----------------------------------------------------------------------

.PHONY: plot_cell_density_truth_goal
plot_cell_density_truth_goal: $(foreach i,$(FCS),$(dir_plot_cell_density_truth)/$(i)_$(METHOD)_cell_density_density.pdf)

define plot_cell_density_truth_rule
$(dir_plot_cell_density_truth)/$(1)_$(METHOD)_cell_density_density.pdf: $(dir_truth)/$(1)_$(METHOD)_trajectory.txt $(RCODE)/02_plot_cell_density_over_time.R
	$R "--args rwd='$(RWD_MAIN)' outdir='$(dir_plot_cell_density_truth)' prefix='$(1)_$(METHOD)_' path_trajectory='$(dir_truth)/$(1)_$(METHOD)_trajectory.txt'" $(RCODE)/02_plot_cell_density_over_time.R $(ROUT)/02_plot_cell_density_over_time.Rout
endef
$(foreach i,$(FCS),$(eval $(call plot_cell_density_truth_rule,$(i))))


# ----------------------------------------------------------------------
### Plot dimension reduction with trajectories from different methods as a heat
# ----------------------------------------------------------------------

.PHONY: plot_dim_reduction_truth_goal
plot_dim_reduction_truth_goal: $(foreach i,$(FCS),$(foreach j,$(DIM_RED_METHODS),$(dir_plot_dim_reduction_truth)/$(i)_norm_$(METHOD)_$(j)_2d_plot.pdf)) $(foreach i,$(FCS),$(foreach j,$(DIM_RED_METHODS),$(dir_plot_dim_reduction_truth)/$(i)_norm_$(METHOD)_$(j)_3d_plot.pdf))

### 2D
define plot_dim_reduction_2d_truth_rule
$(dir_plot_dim_reduction_truth)/$(1)_norm_$(METHOD)_$(2)_2d_plot.pdf: $(dir_run_dim_reduction)/$(1)_norm_$(2)_2d_data.txt $(dir_truth)/$(1)_$(METHOD)_trajectory.txt $(RCODE)/02_plot_dim_reduction.R
	$R "--args rwd='$(RWD_MAIN)' outdir='$(dir_plot_dim_reduction_truth)' prefix='$(1)_norm_$(METHOD)_$(2)_2d_' path_dim_reduction='$(dir_run_dim_reduction)/$(1)_norm_$(2)_2d_data.txt' path_trajectory='$(dir_truth)/$(1)_$(METHOD)_trajectory.txt'" $(RCODE)/02_plot_dim_reduction.R $(ROUT)/02_plot_dim_reduction.Rout
endef
$(foreach i,$(FCS),$(foreach j,$(DIM_RED_METHODS),$(eval $(call plot_dim_reduction_2d_truth_rule,$(i),$(j)))))

### 3D
define plot_dim_reduction_3d_truth_rule
$(dir_plot_dim_reduction_truth)/$(1)_norm_$(METHOD)_$(2)_3d_plot.pdf: $(dir_run_dim_reduction)/$(1)_norm_$(2)_3d_data.txt $(dir_truth)/$(1)_$(METHOD)_trajectory.txt $(RCODE)/02_plot_dim_reduction_3d.R
	$R "--args rwd='$(RWD_MAIN)' outdir='$(dir_plot_dim_reduction_truth)' prefix='$(1)_norm_$(METHOD)_$(2)_3d_' path_dim_reduction='$(dir_run_dim_reduction)/$(1)_norm_$(2)_3d_data.txt' path_trajectory='$(dir_truth)/$(1)_$(METHOD)_trajectory.txt'" $(RCODE)/02_plot_dim_reduction_3d.R $(ROUT)/02_plot_dim_reduction_3d.Rout
endef
$(foreach i,$(FCS),$(foreach j,$(DIM_RED_METHODS),$(eval $(call plot_dim_reduction_3d_truth_rule,$(i),$(j)))))


# ----------------------------------------------------------------------
### Plot marker expression over time for the truth trajectory
# ----------------------------------------------------------------------

.PHONY: plot_markers_truth_goal
plot_markers_truth_goal: $(foreach i,$(FCS),$(dir_plot_markers_truth)/$(i)_norm_$(METHOD)_markers_density.pdf)

define plot_markers_truth_rule
$(dir_plot_markers_truth)/$(1)_norm_$(METHOD)_markers_density.pdf: $(dir_truth)/$(1)_$(METHOD)_trajectory.txt $(dir_fcs_norm)/$(1)_norm.fcs $(RCODE)/02_plot_markers_over_time.R
	$R "--args rwd='$(RWD_MAIN)' outdir='$(dir_plot_markers_truth)' prefix='$(1)_norm_$(METHOD)_' path_trajectory='$(dir_truth)/$(1)_$(METHOD)_trajectory.txt' path_fcs_file='$(dir_fcs_norm)/$(1)_norm.fcs'" $(RCODE)/02_plot_markers_over_time.R $(ROUT)/02_plot_markers_over_time.Rout
endef
$(foreach i,$(FCS),$(eval $(call plot_markers_truth_rule,$(i))))


























###
