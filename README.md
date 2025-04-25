# OptimalSampling

An R Package for Sensitivity Analysis for Treatment (Causal) Effect via Optimal Sample Split and Multiple Hypothesis Tests

## Overview

`OptimalSampling` is an R package for conducting sensitivity analysis in observational studies with high-dimensional outcomes. It implements the methodology proposed in:

> Yin, Q. and Small, D. (2025). *Optimal Sample Split for Treatment Effect Tests on High Dimensional Outcome Space*. Submitted to Biometrics.

The package allows practitioners to:

- Solve for the optimal sample split fraction to conduct multiple hypothesis tests for the treatment effect.
- Apply robust multiple hypothesis tests on matched pair datasets under the solved (or recommended) optimal sample split fraction. 

## Installation

To install the development version from GitHub:

```R
# install.packages("devtools")
library(devtools)
devtools::install_github("qishuoyin/Optimal_Sampling")
```


## Main Contents
This repository contains two parts: the functions in the package for testing the treatment effect, and the experiments for conducting simulations and applications. The core functions that build up the treatment effect test package are: 


### Core Functions

(1) **Function: `plasmode_datasets()`**  
Generate synthetic datasets with simulated treatment effects for optimal sample split fraction solving. (see `fun_plasmode_datasets.R`)

(2) **Function: `optimal_fraction()`**  
Numerically determine the optimal sample split fraction for maximizing test power. (see `fun_optimal_fraction.R`)

(3) **Function: `evaluation()`**  
Evaluate power across different sample splits. (see `fun_power_evaluation.R`)


### Experiments

The experiments conducted by this package are located in the `exp` folder. They are: 

- Simulations on various sample sizes and outcome space dimensions
- Analysis of NHANES observational datasets of second-hand smoke on children's health



## Usage Example

```R

# Step 0: Load your dataset on outcomes for control
data_control = read.csv("Your_data_control_path")

# Step 1: Generate plasmode dataset
plasmode_dir = 'Your_plasmode_save_directory'
generate_plasmode = plasmode_datasets(data_control, plasmode_dir, sim_num=1000, effect_ratio=0.1, effect_size_lower=0.05, effect_size_upper=0.2)

# Step 2: Solve optimal sample split fraction
Gamma_vec = c(1, 1.25, 1.5, 1.75, 2) # different design sensitivity Gamma
xi_vec = seq(from = 0.02, to = 0.98, by = 0.02) # different analysis sample fraction
final_result_dir = 'Your_final_result_save_directory'
result_file_name = 'Your_final_result_file_name'
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



