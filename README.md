# OptimalSampling

R package and paper-reproduction code for optimal sample splitting with multiple
hypothesis tests in observational studies.

## Table of Contents

- [Overview](#Overview)
- [Installation](#Installation)
- [Contents](#Contents)
- [Example](#Example)
- [Reference](#Reference)
- [Authors](#Authors)


## Overview

`OptimalSampling` is an R package for conducting sensitivity analysis in observational studies with high-dimensional outcomes. It implements the methodology proposed in:

> Yin, Q. and Small, D. (2025). *Optimal Sample Split for Treatment Effect Tests on High Dimensional Outcome Space*. Submitted to Biometrics.

The package allows practitioners to:

- Solve for the optimal sample split fraction to conduct multiple hypothesis tests for the treatment effect.
- Apply robust multiple hypothesis tests on matched pair datasets under the solved (or recommended) optimal sample split fraction. 

## Installation

To install the development version from GitHub:

```R
# install.packages("devtools") # only uncomment this line if you never install "devtools" before
library(devtools)
devtools::install_github("qishuoyin/Optimal_Sampling")
```

### Environment for running the experiments (HPC)

Two root-level files reproduce the R environment the experiment scripts use:

- **`environment.yml`** — creates the `optimal_sampling_env` conda environment that the SLURM
  scripts activate:
  ```bash
  conda env create -f environment.yml
  conda activate optimal_sampling_env
  Rscript install_packages.R        # finishes CRAN-only packages (e.g. simDAG)
  ```
- **`install_packages.R`** — idempotently installs the R package dependencies from CRAN. Use it
  to top up the conda env, or on its own with an R module (`module load R/4.5.x`).

The paper experiments require `simDAG` for new affected-proportion datasets and
`MatchIt`/`optmatch` for full matching. The setup files also install the dependencies used by
the original data-generation, application, and visualization scripts.


## Contents
Reusable statistical computation lives in the package under `R/`. Paper-specific
configuration, runners, and artifact builders live under `exp/`.


### Core Functions

(1) **Function: `plasmode_datasets()`**  
Generate synthetic datasets with simulated treatment effects for optimal sample split fraction solving. (see `fun_plasmode_datasets.R`)

(2) **Function: `optimal_fraction()`**  
Numerically determine the optimal sample split fraction for maximizing test power. (see `fun_optimal_fraction.R`)

(3) **Function: `evaluation()`**  
Evaluate power across different sample splits. (see `fun_power_evaluation.R`)


### Experiments

The repository retains exactly three paper experiments:

- [`exp/exp1_simulation`](exp/exp1_simulation/README.md): simulation power and error
  metrics, including Tables 1/S1/S5--S7 and Figures 1/S4.
- [`exp/exp2_application`](exp/exp2_application/README.md): the NHANES application,
  Tables 2--3, and Figure S6.
- [`exp/exp3_sensitivity`](exp/exp3_sensitivity/README.md): the four planning-sensitivity
  studies reported in Tables S2--S4/S8 and Figures S1--S3/S5.

Error rates are outcomes of Experiment 1 and are computed from the same rejection
matrices as power. There is no separate error-rate experiment or `exp4`.



## Example

```R


library(OptimalSampling)

# Step 0: Load your dataset on outcomes for control
data_control = read.csv("Your_data_control_path")

# Step 1: Generate plasmode dataset
plasmode_dir = "Your_plasmode_save_directory"
generate_plasmode = plasmode_datasets(data_control, plasmode_dir, sim_num=1000, effect_ratio=0.1, effect_size_lower=0.05, effect_size_upper=0.2)

# Step 2: Solve optimal sample split fraction
Gamma_vec = c(1, 1.25, 1.5, 1.75, 2) # different design sensitivity Gamma
xi_vec = seq(from = 0.02, to = 0.98, by = 0.02) # different analysis sample fraction
plasmode_dir = "Your_plasmode_dataset_save_directory"
final_result_dir = "Your_final_result_save_directory"
result_file_name = "Your_final_result_file_name"
final_result_mat = optimal_fraction(data_control, sim_num=1000, effect_ratio=0.1, effect_size_lower=0.05, effect_size_upper=0.2, Gamma_vec, xi_vec, err_tolerant=0.01, method="rank", plasmode_dir, test_result_dir=NULL, final_result_dir, result_file_name)

# Step 3: Conduct the two-stage tests on the original dataset by the optimal sample split fraction
Gamma_test = 1.5
optimal_fraction = 0.9
data_pair = read.csv("Your_data_pair_path")
test_result = treatment_detection(Gamma=Gamma_test, xi=optimal_fraction, V=data_pair, method="rank")

```


## Reference

If you want to use this package, please cite the following paper:

> Yin, Q. and Small, D. (2025). *Optimal Sample Split for Treatment Effect Tests on High Dimensional Outcome Space*. Biometrics (Submitted).

## Authors

- **Qishuo Yin**\
  Department of Operations Research and Financial Engineering, Princeton University\
  Email: [qy1448@princeton.edu](mailto\:qy1448@princeton.edu)

- **Dylan Small**\
  Department of Statistics and Data Science, University of Pennsylvania\
  Email: [dsmall@wharton.upenn.edu](mailto\:dsmall@wharton.upenn.edu)

---

This package is actively maintained. Contributions and feedback are welcome.


