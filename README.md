# Chlorhexidine_Tolerance_Hospital_Environments
This repository hosts analysis code for the paper "Hospital environments harbor chlorhexidine tolerant bacteria potentially linked to chlorhexidine persistence in the environment."

**Please cite:**  
> Shen, Jiaxian, Yuhan Weng, Tyler Shimada, Meghana Karan, Andrew Watson, Rachel L. Medernach, Vincent B. Young, Mary K. Hayden, and Erica M. Hartmann. "Hospital environments harbor chlorhexidine tolerant bacteria potentially linked to chlorhexidine persistence in the environment." medRxiv (2024): 2024-10.

Please feel free to contact [Erica Hartmann](erica.hartmann@northwestern.edu) or [Jiaxian Shen](jiaxianshen2022@u.northwestern.edu) if you have any questions or need intermediate data files (e.g., RData).

The directory structure is as follows:
* `bioinformatics_bash_src/`: Bash scripts used to process whole genome sequences of bacteria isolates.
* `fig_src/`: Source code used to generate figures. See Figure Guide.

# Figure Guide
The source code for figures can be found in the following scripts in `fig_src/`. 
* 1a: `chx_persistence.R`
* 1b: `chx_persistence.R`
* 1c: `chx_strain_survival.R`
* 2a: `CFU_normalized_by_area.R`
    - Search "2_CFU_cm2_location_touch.pdf" for the specific chunk of code that generates 2a.
* 2b: `CFU_normalized_by_area.R`
    - Search "8_chx_res_location_touch_box.pdf" and "9(1)_chx_res_location_touch_bin_bubble.pdf" for the specific chunk of code that generates 2b.
* 2c: `plot_with_factors.R`
* 3a: Illustrated in Inkscape based on results in Table S4 and ANI values.
* 3b: #TBD: Andrew#
* 4a: `04_03_plot_high_mic_isolates.R`
    - Search "p_high_species_resistance_mechanism_distribution.pdf" for the specific chunk of code that generates the figure.
* 4b: 
    - Search "p_high_isolates_ARG_1.pdf" for the specific chunk of code that generates the figure.
* 4c: 
    - Search "p_high_isolates_ARG_2.pdf" for the specific chunk of code that generates the figure.
* 5a: `04_01_plot_3_species.R`
* 5b: `04_01_plot_3_species.R`
* 5c: `04_04_plot_Aradi.R`
* 5d: `04_01_plot_3_species.R`
* 6a: `04_02_plot_CHG_genes_colocation.R`
* 6b: #TBD: Andrew#
* 6c: #TBD: Andrew#

Due to GitHub's file size restrictions, intermediate data files cannot be uploaded. Please contact the authors to obtain the data files if needed.
