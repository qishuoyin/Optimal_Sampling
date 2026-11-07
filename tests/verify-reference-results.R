# Optional exhaustive verification against the immutable adjacent revision results.
# Run after package installation with OPTIMAL_SAMPLING_REFERENCE_ROOT set.

library(OptimalSampling)
root <- Sys.getenv("OPTIMAL_SAMPLING_REFERENCE_ROOT")
if (!nzchar(root)) {
  cat("Skipping external reference verification; OPTIMAL_SAMPLING_REFERENCE_ROOT is unset\n")
} else {
summary_path <- file.path(
  root, "exp/exp_revision/results/revision-required-original-grid/final/table1_error_rates.csv"
)
expected <- read.csv(summary_path, stringsAsFactors = FALSE)
truth <- seq_len(1000L) <= 100L

for (index in seq_len(nrow(expected))) {
  path <- expected$rejection_vector_path[[index]]
  object <- if (grepl("[.]csv$", path, ignore.case = TRUE)) {
    read.csv(path, check.names = FALSE)
  } else {
    readRDS(path)
  }
  rejected <- if (is.list(object) && !is.null(object$analysis_result)) object$analysis_result else object
  actual <- summarize_rejections(rejected, truth)
  columns <- c("power", "FPR", "FWER", "FDR")
  for (metric in columns) {
    expected_name <- paste0(metric, "_mean")
    actual_name <- expected_name
    if (!isTRUE(all.equal(actual[[actual_name]], expected[[expected_name]][[index]], tolerance = 1e-14))) {
      stop("reference mismatch in row ", index, " metric ", metric)
    }
  }
}
cat("Verified", nrow(expected), "Experiment 1 power/error cells against immutable rejection vectors\n")
}
