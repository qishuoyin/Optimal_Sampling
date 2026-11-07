# Experiment 1: simulation and error metrics

This directory now owns main-paper Table 1 and Figure 1 and supplement Tables S1 and
S5--S7 and Figure S4. Power, FPR, FWER, FDR, and rejection counts are calculated from the
same rejection matrices; there is no separate error-rate experiment.

The versioned scientific grid is `config/paper_grid.csv`. After installing the package, run
one `(I, K, method)` job with `run.R`; use `build_artifacts.R` after all 64 jobs finish.

```bash
Rscript exp/exp1_simulation/run.R \
  --I 200 --K 1000 --method rank \
  --input-dir /path/to/data_simulation \
  --output-dir /path/to/exp1-results

Rscript exp/exp1_simulation/build_artifacts.R \
  /path/to/exp1-results /path/to/artifacts
```

Methods are `Bonferroni`, `naive`, `select`, and `rank`. The latter two names preserve the
implementation that generated the published results; paper-facing labels are applied only when
artifacts are built.

The builder verifies all 320 final cells and all 23,760 split-fraction cells before writing
artifacts. Fresh metrics are kept separate from the checked compatibility fixtures under
`reference/`, which retain the values printed in the current paper and supplement.
