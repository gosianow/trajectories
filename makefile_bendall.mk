### Define the version of R and the path to software
R := R_LIBS_SITE=/home/gosia/programs/Rlibraries/BioC34/:/home/Shared/Rlib/release-3.4-lib/ /usr/local/R/R-3.3.1/bin/R CMD BATCH --no-restore --no-save
### cd /home/Shared/data/cytof/trajectories_data
RWD_MAIN := .
RCODE := $(RWD_MAIN)/trajectories_code
RWD := $(RWD_MAIN)/bendall_cytof
ROUT := $(RWD)/Rout

dir_fcs_orig := $(RWD)/01_fcs_orig
dir_fcs := $(RWD)/01_fcs
dir_panel := $(RWD)/01_panel
dir_fcs_norm := $(RWD)/01_fcs_norm
dir_plot_data_distr := $(RWD)/02_plot_data_distr
dir_run_dim_reduction := $(RWD)/02_run_dim_reduction
dir_results := $(RWD)/03_results
dir_plot_cell_density := $(RWD)/04_plot_cell_density
dir_plot_dim_reduction := $(RWD)/04_plot_dim_reduction
dir_plot_markers := $(RWD)/04_plot_markers

### Define a list of FCS files that should be analyzed
FCS_ORIG := Bendall_et_al_Cell_Sample_A_basal Bendall_et_al_Cell_Sample_B_basal Bendall_et_al_Cell_Sample_C_basal Bendall_et_al_Cell_Sample_D_basal
FCS := bendall_sample_a bendall_sample_b bendall_sample_c bendall_sample_d
INDEX := 1 2 3 4
DATA := bendall

## Define the default rule (makefiles are usually written so that the first target is for compiling the entire program)
.PHONY: all
all: mkdir_rout $(foreach i,$(FCS),$(dir_fcs_norm)/$(i)_norm.rds) plot_data_distr_goal plot_cell_density_goal plot_dim_reduction_goal plot_markers_goal


### Make sure no intermediate files are deleted
.SECONDARY:

.PHONY: mkdir_rout
mkdir_rout:
	mkdir -p $(ROUT)

##########################################################################################################
### Data extracting
##########################################################################################################

# ----------------------------------------------------------------------
### Copy specified fcs files from dir_fcs_orig/ to dir_fcs/
# ----------------------------------------------------------------------

define copy_fcs_rule
$(dir_fcs)/$(word $(1),$(FCS)).fcs: $(dir_fcs_orig)/$(word $(1),$(FCS_ORIG)).fcs
	mkdir -p $(dir_fcs)
	cp $(dir_fcs_orig)/$(word $(1),$(FCS_ORIG)).fcs $(dir_fcs)/$(word $(1),$(FCS)).fcs
endef
$(foreach i,$(INDEX),$(eval $(call copy_fcs_rule,$(i))))


# ----------------------------------------------------------------------
### Create panel
# ----------------------------------------------------------------------

$(dir_panel)/$(DATA)_panel.txt: $(dir_fcs)/$(word 1,$(FCS)).fcs $(RCODE)/00_panel_$(DATA)_cytof.R
	$R "--args rwd='$(RWD_MAIN)' path_fcs_file='$(dir_fcs)/$(word 1,$(FCS)).fcs' outdir_panel='$(dir_panel)' prefix='$(DATA)_'" $(RCODE)/00_panel_$(DATA)_cytof.R $(ROUT)/00_panel_$(DATA)_cytof.Rout



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
### Run different methods
##########################################################################################################

# ----------------------------------------------------------------------
### Get the wanderulst trajectories that were obtained by Bendall et al.
# ----------------------------------------------------------------------

METHOD := wanderlust0

define get_wanderlust_rule
$(dir_results)/$(METHOD)/$(1)_$(METHOD)_trajectory.txt: $(dir_fcs)/$(1).fcs
	$R "--args rwd='$(RWD_MAIN)' path_fcs_file='$(dir_fcs)/$(1).fcs' outdir='$(dir_results)/$(METHOD)' prefix='$(1)_$(METHOD)_'" $(RCODE)/03_get_wanderlust.R $(ROUT)/03_get_wanderlust.Rout
endef
$(foreach i,$(FCS),$(eval $(call get_wanderlust_rule,$(i))))


##########################################################################################################
### Plot results of different methods
##########################################################################################################

METHODS := wanderlust0

# ----------------------------------------------------------------------
### Plot cell density over time for different trajectory method
# ----------------------------------------------------------------------

.PHONY: plot_cell_density_goal
plot_cell_density_goal: $(foreach i,$(FCS),$(foreach j,$(METHODS),$(dir_plot_cell_density)/$(i)_$(j)_cell_density_density.pdf))

define plot_cell_density_rule
$(dir_plot_cell_density)/$(1)_$(2)_cell_density_density.pdf $(dir_plot_cell_density)/$(1)_$(2)_cell_density_hist.pdf: $(dir_results)/$(2)/$(1)_$(2)_trajectory.txt $(RCODE)/02_plot_cell_density_over_time.R
	$R "--args rwd='$(RWD_MAIN)' outdir='$(dir_plot_cell_density)' prefix='$(1)_$(2)_' path_trajectory='$(dir_results)/$(2)/$(1)_$(2)_trajectory.txt'" $(RCODE)/02_plot_cell_density_over_time.R $(ROUT)/02_plot_cell_density_over_time.Rout
endef
$(foreach i,$(FCS),$(foreach j,$(METHODS),$(eval $(call plot_cell_density_rule,$(i),$(j)))))


# ----------------------------------------------------------------------
### Plot dimension reduction with trajectories from different methods as a heat
# ----------------------------------------------------------------------

.PHONY: plot_dim_reduction_goal
plot_dim_reduction_goal: $(foreach i,$(FCS),$(foreach j,$(METHODS),$(foreach k,$(DIM_RED_METHODS),$(dir_plot_dim_reduction)/$(i)_norm_$(j)_$(k)_2d_plot.pdf))) $(foreach i,$(FCS),$(foreach j,$(METHODS),$(foreach k,$(DIM_RED_METHODS),$(dir_plot_dim_reduction)/$(i)_norm_$(j)_$(k)_3d_plot.pdf)))

### 2D
define plot_dim_reduction_2d_rule
$(dir_plot_dim_reduction)/$(1)_norm_$(2)_$(3)_2d_plot.pdf: $(dir_run_dim_reduction)/$(1)_norm_$(3)_2d_data.txt $(dir_results)/$(2)/$(1)_$(2)_trajectory.txt $(RCODE)/02_plot_dim_reduction.R
	$R "--args rwd='$(RWD_MAIN)' outdir='$(dir_plot_dim_reduction)' prefix='$(1)_norm_$(2)_$(3)_2d_' path_dim_reduction='$(dir_run_dim_reduction)/$(1)_norm_$(3)_2d_data.txt' path_trajectory='$(dir_results)/$(2)/$(1)_$(2)_trajectory.txt'" $(RCODE)/02_plot_dim_reduction.R $(ROUT)/02_plot_dim_reduction.Rout
endef
$(foreach i,$(FCS),$(foreach j,$(METHODS),$(foreach k,$(DIM_RED_METHODS),$(eval $(call plot_dim_reduction_2d_rule,$(i),$(j),$(k))))))

### 3D
define plot_dim_reduction_3d_rule
$(dir_plot_dim_reduction)/$(1)_norm_$(2)_$(3)_3d_plot.pdf: $(dir_run_dim_reduction)/$(1)_norm_$(3)_3d_data.txt $(dir_results)/$(2)/$(1)_$(2)_trajectory.txt $(RCODE)/02_plot_dim_reduction_3d.R
	$R "--args rwd='$(RWD_MAIN)' outdir='$(dir_plot_dim_reduction)' prefix='$(1)_norm_$(2)_$(3)_3d_' path_dim_reduction='$(dir_run_dim_reduction)/$(1)_norm_$(3)_3d_data.txt' path_trajectory='$(dir_results)/$(2)/$(1)_$(2)_trajectory.txt'" $(RCODE)/02_plot_dim_reduction_3d.R $(ROUT)/02_plot_dim_reduction_3d.Rout
endef
$(foreach i,$(FCS),$(foreach j,$(METHODS),$(foreach k,$(DIM_RED_METHODS),$(eval $(call plot_dim_reduction_3d_rule,$(i),$(j),$(k))))))


# ----------------------------------------------------------------------
### Plot marker expression over time for different trajectory method
# ----------------------------------------------------------------------

.PHONY: plot_markers_goal
plot_markers_goal: $(foreach i,$(FCS),$(foreach j,$(METHODS),$(dir_plot_markers)/$(i)_norm_$(j)_markers_density.pdf))

define plot_markers_rule
$(dir_plot_markers)/$(1)_norm_$(2)_markers_density.pdf: $(dir_results)/$(2)/$(1)_$(2)_trajectory.txt $(dir_fcs_norm)/$(1)_norm.fcs $(RCODE)/02_plot_markers_over_time.R
	$R "--args rwd='$(RWD_MAIN)' outdir='$(dir_plot_markers)' prefix='$(1)_norm_$(2)_' path_trajectory='$(dir_results)/$(2)/$(1)_$(2)_trajectory.txt' path_fcs_file='$(dir_fcs_norm)/$(1)_norm.fcs'" $(RCODE)/02_plot_markers_over_time.R $(ROUT)/02_plot_markers_over_time.Rout
endef
$(foreach i,$(FCS),$(foreach j,$(METHODS),$(eval $(call plot_markers_rule,$(i),$(j)))))































###
