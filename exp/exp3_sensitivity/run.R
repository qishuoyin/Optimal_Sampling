#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 4L) {
  stop("usage: run.R MANIFEST JOB_INDEX INPUT_ROOT OUTPUT_DIR")
}
suppressPackageStartupMessages(library(OptimalSampling))
manifest <- read.csv(args[[1L]], stringsAsFactors = FALSE)
job <- manifest[as.integer(args[[2L]]), , drop = FALSE]
if (nrow(job) != 1L) stop("invalid job index")
input_root <- normalizePath(args[[3L]], mustWork = TRUE)
output_dir <- normalizePath(args[[4L]], mustWork = FALSE)
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

with_seed <- function(seed, expression) {
  set.seed(as.integer(seed))
  eval.parent(substitute(expression))
}
label <- function(x) format(x, trim = TRUE, scientific = FALSE)
legacy_path <- function(kind) file.path(
  input_root, "exp/exp1_simulation/data/data_simulation",
  paste0("data_simulation_", kind, "_outcome_", job$K, "_Gamma_", label(job$Gamma),
         "_I_", job$I, "_test_sim_", job$outer_id, ".csv")
)

if (job$eta_true == 0.10 && all(file.exists(vapply(c("diff", "control"), legacy_path, character(1))))) {
  difference <- read.csv(legacy_path("diff"), check.names = FALSE)
  control <- read.csv(legacy_path("control"), check.names = FALSE)
  source <- "original_exp1_inputs"
} else {
  population <- with_seed(job$seed_pool, generate_simulation_population(
    N = 5000L, K = job$K, D = 5L, Gamma = job$Gamma, eta = job$eta_true
  ))
  matched <- construct_matched_outcomes(population$X, population$Z, population$Y)
  sampled <- with_seed(job$seed_outer, sample_matched_outcomes(matched, job$I))
  difference <- sampled$difference
  control <- sampled$control
  source <- "generated_population"
}
truth <- seq_len(job$K) <= round(job$eta_true * job$K)
M_values <- as.integer(strsplit(job$M_values, ";", fixed = TRUE)[[1L]])
result <- run_sensitivity_cell(
  control, difference, Gamma = job$Gamma, method = job$method,
  M_values = M_values, eta_work = job$eta_work, effect_id = job$effect_id,
  truth = truth, seed_plasmode = job$seed_plasmode,
  seed_final_split = job$seed_final_split
)
result$job <- job
result$source <- source
saveRDS(result, file.path(output_dir, paste0(job$job_id, ".rds")))
