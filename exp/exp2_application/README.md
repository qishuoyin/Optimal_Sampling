# Experiment 2: Real Data Application

This directory contains experiments applying the proposed optimal sampling strategies to a real-world dataset. The goal is to demonstrate the practical utility of the **Optimal Sample Split Rank Tests** on observational data, comparing their performance against the baseline **Bonferroni Correction**.


## Main Application Scripts

- `solve_optimal_fraction_plasmode_ratio_0_1_effectsize_0_2_gamma_1.25.R`: Solves for the optimal planning fraction numerically using a plasmode design and specified effect size and sensitivity parameters.
  
- `application_final_test_optimal_sampling.R`: Applies the optimal sample split method (rank-based) on the cleaned real dataset. This script computes test statistics and evaluates results under realistic design sensitivity scenarios.

- `application_final_test_vanilla_Bonferroni.R`: Applies the standard Bonferroni correction method to the same dataset, serving as a benchmark for comparison.


## Input/Output Data

- `data_full_cleaned.csv`: The cleaned dataset used in the application study. This includes outcomes, treatment indicators, and other covariates.

- `final_results.csv`: Contains the results from the real data analysis, including test outcomes and power estimates for both proposed and baseline methods.


## Subdirectories

📁 `visualization/`:  
Stores visualization scripts and output plots for result inspection and covariate balance checks.
- `application_covariates_plots.R`: Generates diagnostic plots for covariates across treatment groups.
- `pretreatment_covariates_boxplot.png`: Sample output illustrating covariate distributions pre-treatment.

📁 `scripts/`:  
(If included) This folder is intended to contain `.sh` shell scripts for submitting application analyses and plotting jobs to HPC systems such as Slurm. These scripts parallel the structure in `exp1_simulation/scripts/`.


## Notes

- All `.R` scripts assume the working directory is at the top level of the project.
- Results are written to structured output folders for downstream visualization and analysis.
- Helper functions (e.g., for power evaluation or matrix operations) are expected to be loaded from the shared `R/` directory.

This directory complements the simulation studies in `exp1_simulation/` by validating the proposed sample split methods on real observational data.
