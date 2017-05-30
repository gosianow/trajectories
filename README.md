# Comparison of trajectory estimation algorithms for CyTOF data

The project directory should contain the following:

- directory `data_bendall/01_fcs_orig` with the fcs files 
		- `Bendall_et_al_Cell_Sample_A_basal` 
		- `Bendall_et_al_Cell_Sample_B_basal` 
		- `Bendall_et_al_Cell_Sample_C_basal` 
		- `Bendall_et_al_Cell_Sample_D_basal`

- directory `data_sim1/01_data_mat` with the `albeck2008_Poisson_10000_25000_100.mat` file


Run the Bendall data analysis by executing 

```
$ make -f makefile_bendall.mk
```

Run the simulation analysis by executing 

```
$ make -f makefile_sim1.mk
```


