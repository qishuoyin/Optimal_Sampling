# Experiment 2: Real Data Application

This directory contains experiments applying the proposed optimal sampling strategies to a real-world dataset. The goal is to demonstrate the practical utility of the **Optimal Sample Split Selection Tests** and **Optimal Sample Split Rank Tests** on observational data, comparing their performance against the baseline **Bonferroni Correction**.

---

## Main Application Scripts

- `application_final_test_optimal_sampling.R`: Applies the optimal sample split method (selection-based or rank-based) on the cleaned real dataset. This script computes test statistics and evaluates results under realistic design sensitivity scenarios.

- `application_final_test_vanilla_Bonferroni.R`: Applies the standard Bonferroni correction method to the same dataset, serving as a benchmark for comparison.

- `solve_optimal_fraction_plasmode_ratio_0_1_effectsize_0_2_gamma_1.25.R`: Solves for the numerically optimal planning fraction using a plasmode design and specified effect size and sensitivity parameters. This script supports sample split tuning and optimization for the main application.

---

## Input/Output Data

- `data_full_cleaned.csv`: The cleaned dataset used in the application study. This file contains observed outcomes, treatment indicators, and potential covariates structured for downstream hypothesis testing.

- `final_results.csv`: Contains the results from the real data analysis, including test decisions and power estimates from both proposed and baseline methods.

---

## Notes

- All `.R` scripts assume the working directory is at the top level of the project.
- Before running the application scripts, ensure necessary helper functions are accessible (e.g., from the `R/` folder).
- The planning fractions and design sensitivity levels can be modified in each script to explore robustness.

This directory complements the simulation studies by validating the proposed methods on actual data with potentially unmeasured confounding.
