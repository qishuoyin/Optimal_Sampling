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

## Methodology

The two-stage sample split methodology implemented is built on sample splitting and multiple hypothesis testing:

- **Stage 1** (Planning): Use a split of the matched data to identify promising outcomes (selection or rank).
- **Stage 2** (Testing): Use the remaining data to evaluate the treatment effects.

The sample split fraction can be the solution of the optimal fraction by the simulations on the semi-synthetic plasmode datasets or adapted from the empirical recommended ones. 

### Two Main Test Types:

- `Optimal Sample Split Selection Test`: Controls family-wise error rate (FWER).
- `Optimal Sample Split Rank Test`: Controls false discovery rate (FDR).


## Main Contents in the Repository

This repository contains two parts - the functions in the package to test for the treatment effect, and the experiments to conduct the simulations and application. The core functions that build up the treatment effect test package are: 


## Core Functions

(1) **Function: `plasmode_datasets()`**  
Generate synthetic datasets with simulated treatment effects for optimal sample split fraction solving. (see `fun_plasmode_datasets.R`)

(2) **Function: `optimal_fraction()`**  
Numerically determine the optimal sample split fraction for maximizing test power. (see `fun_optimal_fraction.R`)

(3) **Function: `evaluation()`**  
Evaluate power across different sample splits. (see `fun_power_evaluation.R`)


## Usage Example

```R
# Step 1: Generate or load matched pairs dataset (I pairs, K outcomes)
# Example: I = 200, K = 100

# Step 2: Generate plasmode datasets
plasmodes <- fun_plasmode_datasets(data, eta = 0.1, effect_size_range = c(0.05, 0.2))

# Step 3: Determine optimal split fraction
opt_frac <- fun_optimal_fraction(plasmodes)

# Step 4: Run two-stage rank test on the original dataset
results <- fun_two_stage_tests(data, split_frac = opt_frac, method = "rank")
```

## Applications

- Causal inference with high-dimensional biomedical or social science data
- Robust treatment effect detection under potential unmeasured confounding
- Analysis of NHANES or other public health observational datasets

## Reference

If you want to use this package, please cite the following paper:

> Yin, Q. and Small, D. (2025). *Optimal Sample Split for Treatment Effect Tests on High Dimensional Outcome Space*. Biometrics (Submitted).

## Authors

- **Qishuo Yin**\
  Department of Operations Research and Financial Engineering, Princeton University\
  Email: [qy1448@princeton.edu](mailto\:qy1448@princeton.edu)

- **Dylan Small**\
  Department of Statistics and Data Science, University of Pennsylvania
  Email: [dsmall@wharton.upenn.edu](mailto\:dsmall@wharton.upenn.edu)

---

This package is actively maintained. Contributions and feedback are welcome.



