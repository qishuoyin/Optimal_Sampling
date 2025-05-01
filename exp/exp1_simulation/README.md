# Experiment 1: Simulation Studies

This directory contains experiments evaluating the performance of various optimal sampling strategies under synthetic high-dimensional data. The experiments compare the proposed *Optimal Sample Split Selection Tests* and *Optimal Sample Split Rank Tests* with the baseline methods, *Naive (Traditional) Sample Split Test* and *Bonferroni Correction*. 

---

## Main Simulation Scripts

### `vanilla_method_Bonferroni.R`
**Purpose**:  
Implements a baseline Bonferroni correction method for multiple testing. Serves as a reference for evaluating the power and sensitivity of proposed methods.

### `optimal_sampling_method_naive.R`
**Purpose**:  
Runs a naive version of the optimal sampling strategy that performs hypothesis testing without using any planning sample.

### `optimal_sampling_method_select.R`
**Purpose**:  
Implements the "selection-based" optimal sample split method. Uses a small planning sample to select promising hypotheses before conducting confirmatory tests on an independent analysis sample.

### `optimal_sampling_method_rank.R`
**Purpose**:  
Implements the "ranking-based" optimal sample split method. Hypotheses are ranked using statistics from the planning sample, and the analysis sample is used to evaluate those ranks.

---

## Subdirectories

### 📁 `data_generate_script/`
**Purpose**:  
Contains scripts for simulating synthetic datasets with structured treatment effects.

- `data_generate.R`: Main function to simulate synthetic treatment/control datasets.
- `data_match_pair.R` / `data_match_pair_parallel.R`: Generate matched-pair datasets for simulation.
- `data_sample_simulation.R`: Simulates observed outcomes under a treatment-control structure.
- `*_example.R` and `*_parallel.R`: Variants for demonstration and parallel execution.

---

### 📁 `visualization/`
**Purpose**:  
Provides scripts to create performance visualizations (e.g., power curves) from simulation results.

- `example_power_plot.R`: Plots power curves from saved results.
- `optimal_sampling_method_select_plot_example.R`: Visualizes selection method outcomes.
- Output PDFs or images are saved for inclusion in reports or papers.

---

### 📁 `scripts/`
**Purpose**:  
Stores shell scripts (`.sh`) designed for HPC job submission, especially for Slurm-based clusters. These scripts allow for parallel or array-based execution of simulation and plotting jobs.

Examples:
- `*_array.sh`: Submits a job array for multiple simulations.
- `*_plot_example.sh`: Runs plotting scripts on cluster nodes.

---

## Notes

- All `.R` scripts assume the working directory is at the top level of the project.
- Simulation results are saved to `output/` folders organized by method and parameters.
- Use scripts from the `scripts/` folder to automate large-scale simulation or plotting tasks in HPC environments.

This structure is intended to separate core logic (`.R` scripts), HPC batch utilities (`scripts/`), data generation (`data_generate_script/`), and post-processing (`visualization/`).
