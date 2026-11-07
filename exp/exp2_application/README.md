# Experiment 2: real-data application

The package-driven entry point is `run.R`. It reproduces the paper's fixed 90% analysis split
for all five sensitivity bounds and writes both the rank-method and full-sample Bonferroni
decisions from the same input data. `build_artifacts.R` converts those decisions into main-paper
Tables 2 and 3. Supplement Figure S6 remains the covariate-balance artifact.

```bash
Rscript exp/exp2_application/run.R /path/to/results
Rscript exp/exp2_application/build_artifacts.R \
  /path/to/results/application_results.rds /path/to/artifacts
```

The versioned application input contains 153 matched pairs and 76 outcomes. The artifact
builder also recreates supplement Figure S6 from `data_full_cleaned.csv`.

