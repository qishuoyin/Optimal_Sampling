#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)
if (length(args) > 1L) stop("usage: run.R [OUTPUT_DIR]")
suppressPackageStartupMessages(library(OptimalSampling))
script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script_path <- if (length(script_arg)) sub("^--file=", "", script_arg[[1L]]) else getwd()
experiment_dir <- normalizePath(dirname(script_path), mustWork = TRUE)
output_dir <- if (length(args)) normalizePath(args[[1L]], mustWork = FALSE) else experiment_dir
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

difference <- read.csv(file.path(experiment_dir, "data_pair_diff.csv"), check.names = FALSE)
config_table <- read.csv(
  file.path(experiment_dir, "config", "application.csv"),
  stringsAsFactors = FALSE
)
config <- stats::setNames(config_table$value, config_table$parameter)
Gamma_values <- as.numeric(strsplit(config[["Gamma"]], ";", fixed = TRUE)[[1L]])
analysis_fraction <- as.numeric(config[["analysis_fraction"]])
seed <- as.integer(config[["seed"]])
if (nrow(difference) != as.integer(config[["matched_pairs"]]) ||
    ncol(difference) != as.integer(config[["outcomes"]])) {
  stop("application data dimensions do not match config/application.csv")
}
set.seed(seed)
optimal <- t(vapply(Gamma_values, function(Gamma) {
  treatment_detection(Gamma, analysis_fraction, difference, config[["method"]])$analysis_result
}, numeric(ncol(difference))))
bonferroni <- t(vapply(Gamma_values, function(Gamma) {
  Bonferroni_test(Gamma, difference)
}, numeric(ncol(difference))))
colnames(optimal) <- colnames(difference)
colnames(bonferroni) <- colnames(difference)
write.csv(optimal, file.path(output_dir, "final_results.csv"), row.names = FALSE)
write.csv(bonferroni, file.path(output_dir, "final_results_vanilla_Bonferroni.csv"), row.names = FALSE)
saveRDS(list(Gamma = Gamma_values, analysis_fraction = analysis_fraction,
             optimal = optimal, Bonferroni = bonferroni, seed = seed),
        file.path(output_dir, "application_results.rds"))
