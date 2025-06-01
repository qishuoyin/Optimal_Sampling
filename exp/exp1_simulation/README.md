# Experiment 1: Simulation Studies

This directory contains experiments evaluating the performance of various optimal sampling strategies under synthetic high-dimensional data. The experiments compare the proposed **Optimal Sample Split Selection Tests** and **Optimal Sample Split Rank Tests** with the baseline methods, **Naive (Traditional) Sample Split Test** and **Bonferroni Correction**. 


## Main Simulation Scripts
- `optimal_sampling_method_naive.R`: Implements a naive version of the optimal sampling strategy that performs hypothesis testing with only one outcome selected among the planning sample.
- `optimal_sampling_method_select.R`: Implements the "selection-based" optimal sample split method. A small planning sample is used to select promising hypotheses before conducting confirmatory tests on an independent analysis sample.
- `optimal_sampling_method_rank.R`: Implements the "ranking-based" optimal sample split method. Hypotheses are ranked using statistics from the planning sample, and the analysis sample is used to evaluate those ranks.
- `vanilla_method_Bonferroni.R`: Implements a baseline Bonferroni correction method for multiple testing. Serves as a reference for evaluating the power and sensitivity of proposed methods.


## Subdirectories
📁 `data_generate_script/`: Stores (`.R`) scripts for simulating synthetic datasets with structured treatment effects.

📁 `visualization/`: Stores (`.R`) scripts to create performance visualizations (e.g., power curves) from simulation results.

📁 `script/`: Stores shell scripts (`.sh`) designed for HPC job submission, especially for Slurm-based clusters. These scripts allow for parallel or array-based execution of simulation and plotting jobs.

## Notes

- All `.R` scripts assume the working directory is at the top level of the project.
- Generated datasets are saved to `data/` folders for simulation studies to access.
- Simulation results are saved to `output/` folders organized by method and parameters.
- Use scripts from the `script/` folder to automate large-scale simulation or plotting tasks in HPC environments.
- Helper functions (e.g., for power evaluation or matrix operations) are expected to be loaded from the shared `R/` directory.
- When performing parallel computing on a cluster, we specify the number of cores to use. In our R scripts, this is configured using the following command, though the exact method may vary depending on the cluster environment.

```R
num_cores <- as.numeric(Sys.getenv("SLURM_CPUS_PER_TASK"))
```

This structure is intended to separate core logic (`.R` scripts), HPC batch utilities (`scripts/`), data generation (`data_generate_script/`), and post-processing (`visualization/`).
