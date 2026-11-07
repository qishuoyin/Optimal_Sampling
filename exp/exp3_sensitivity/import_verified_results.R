#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 2L) stop("usage: import_verified_results.R SCENARIO_SUMMARY.csv OUTPUT_DIR")
source <- read.csv(args[[1L]], stringsAsFactors = FALSE, check.names = FALSE)
mapping <- c(
  exp1_M = "plasmode_count",
  exp2_eta = "affected_proportion",
  exp2_fixed_count = "fixed_affected_count",
  exp3_effect = "effect_specification"
)
# The archived effect study also contains an exploratory standardized-uniform
# specification that is absent from the paper and supplement.  Keep only the
# five reported specifications (the baseline is supplied by exp1_M below in
# build_artifacts.R).
keep <- source$experiment %in% names(mapping) &
  !(source$experiment == "exp3_effect" &
      source$effect_id == "uniform_small_standardized")
output <- source[keep, , drop = FALSE]
output$experiment <- unname(mapping[output$experiment])
required <- c(
  "experiment", "I", "K", "Gamma", "method", "M", "eta_true", "eta_work", "effect_id",
  "power_mean", "power_lower", "power_upper", "zeta_star_mean", "zeta_star_lower",
  "zeta_star_upper", "n_outer"
)
missing <- setdiff(required, names(output))
if (length(missing)) stop("verified summary is missing: ", paste(missing, collapse = ", "))
output <- output[, required]
if (nrow(output) != 210L || any(output$n_outer != 30L)) {
  stop("expected 210 paper-supported 30-replication sensitivity cells")
}
dir.create(args[[2L]], recursive = TRUE, showWarnings = FALSE)
write.csv(output, file.path(args[[2L]], "exp3-sensitivity-summary.csv"), row.names = FALSE)
cat("Imported", nrow(output), "paper-supported sensitivity cells\n")
