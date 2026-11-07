# Experiment 3: planning sensitivity

This directory contains only the additional experiments reported in supplement Figures S1--S3
and S5 and Tables S2--S4 and S8: plasmode count, working affected proportion, effect
specification, and fixed affected-count sensitivity.

Build the manifest, run its rows locally or through a scheduler, then aggregate:

```bash
Rscript exp/exp3_sensitivity/build_manifest.R /path/to/manifest.csv
Rscript exp/exp3_sensitivity/run.R /path/to/manifest.csv 1 /path/to/source-repository /path/to/results
Rscript exp/exp3_sensitivity/build_artifacts.R /path/to/results /path/to/artifacts
```

The manifest contains 30 outer replications and only `Gamma = 1, 1.5, 2`. Pilot cells,
reviewer-only outputs, and unreported extra sensitivity bounds are intentionally excluded.
