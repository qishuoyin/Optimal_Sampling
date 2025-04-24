# OptimalSampling

**An R Package for Sensitivity Analysis for Treatment (Causal) Effect via Optimal Sample Split and Multiple Hypothesis Tests**

## Overview

`OptimalSampling` is an R package for conducting sensitivity analysis in observational studies with high-dimensional outcomes. It implements the methodology proposed in:

> Yin, Q. and Small, D. (2025). *Optimal Sample Split for Treatment Effect Tests on High Dimensional Outcome Space*. Submitted to Biometrics.

The package allows practitioners to:

- Solve for the optimal sample split fraction to conduct multiple hypothesis tests for treatment effect.
- Apply robust multiple hypothesis tests on matched pair datasets under the solved (or recommmend) optimal sample split fraction. 

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





## Core Functions

### Function Descriptions

#### `fun_optimal_fraction.R`
**Function: `optimal_fraction()`**  
Numerically determine the optimal sample split fraction for maximizing test power.

**Arguments:**
- `data_control`: Matrix of matched control group outcomes.
- `sim_num`: Number of plasmode datasets to simulate.
- `effect_ratio`: Proportion of affected outcomes.
- `effect_size_lower`, `effect_size_upper`: Effect size bounds.
- `Gamma_vec`: Vector of bias parameters.
- `xi_vec`: Candidate values of split fractions.
- `err_tolerant`: Tolerance level for choosing near-optimal solution.
- `method`: Either `"rank"` or `"select"` (default: "rank").
- `plasmode_dir`: Directory with generated plasmode datasets.
- `test_result_dir`: Optional intermediate result storage.
- `final_result_dir`: Directory for final output.
- `result_file_name`: Output filename.

#### `fun_plasmode_datasets.R`
**Function: `plasmode_datasets()`**  
Generates synthetic datasets with simulated treatment effects.

**Arguments:**
- `data_control`: Matched control matrix.
- `output_dir`: Directory to save results.
- `sim_num`: Number of simulations (default: 1000).
- `effect_ratio`: Ratio of affected outcomes (default: 0.1).
- `effect_size_lower`, `effect_size_upper`: Range of effect sizes.

#### `fun_power_evaluation.R`
**Function: `evaluation()`**  
Computes power across different sample splits.

**Arguments:**
- `effect_vec`: True effect indicators.
- `analysis_result`: Matrix of test outcomes.

**Function: `optimal_solution()`**  
Identifies the best-performing sample split fraction.

**Arguments:**
- `evaluation_vec`: Test power across splits.
- `err_tolerant`: Tolerance range (default: 0.05).

#### `fun_two_stage_tests.R`
Implements the two-stage hypothesis testing procedure.

**Functions and Arguments:**
- `sgn(x)`: Sign function.
- `Wilcoxon_test(vec)`: Signed-rank test.
- `data_split(xi, V)`: Split matched data.
- `planning_test(Gamma, xi, V_planning, method)`: Planning stage.
- `analysis_test(V_analysis, H_order, method)`: Analysis stage.
- `treatment_detection(Gamma, xi, V, method)`: Full pipeline.

#### `fun_vanilla_Bonferroni_test.R`
**Function: `Bonferroni_test()`**  
Baseline FWER control using Bonferroni correction.

**Arguments:**
- `Gamma`: Bias sensitivity level.
- `V`: Paired differences matrix.


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

---

This package is actively maintained. Contributions and feedback are welcome.



