#!/usr/bin/env Rscript

script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script_path <- if (length(script_arg)) sub("^--file=", "", script_arg[[1L]]) else getwd()
experiment_dir <- normalizePath(dirname(script_path), mustWork = TRUE)
args <- commandArgs(trailingOnly = TRUE)
output <- if (length(args)) args[[1L]] else file.path(experiment_dir, "manifest.csv")

read_config <- function(name, experiment) {
  data <- read.csv(file.path(experiment_dir, "config", name), stringsAsFactors = FALSE)
  data$experiment <- experiment
  if ("M" %in% names(data)) data$M_values <- as.character(data$M)
  data[, c("experiment", "I", "K", "Gamma_values", "M_values",
           "eta_true", "eta_work", "effect_id")]
}
spec <- rbind(
  read_config("plasmode_count.csv", "plasmode_count"),
  read_config("affected_proportion.csv", "affected_proportion"),
  read_config("effect_specification.csv", "effect_specification"),
  read_config("fixed_affected_count.csv", "fixed_affected_count")
)
spec <- unique(spec[, c("experiment", "I", "K", "Gamma_values", "M_values",
                        "eta_true", "eta_work", "effect_id")])

rows <- list()
for (index in seq_len(nrow(spec))) {
  Gamma <- as.numeric(strsplit(spec$Gamma_values[[index]], ";", fixed = TRUE)[[1L]])
  for (value in Gamma) for (method in c("select", "rank")) for (outer in seq_len(30L)) {
    row <- spec[index, , drop = FALSE]
    row$Gamma <- value
    row$method <- method
    row$outer_id <- outer
    rows[[length(rows) + 1L]] <- row
  }
}
manifest <- do.call(rbind, rows)
manifest$Gamma_values <- NULL
seed_group <- paste0("I", manifest$I, "_K", manifest$K, "_G", manifest$Gamma)
seed_index <- match(seed_group, sort(unique(seed_group)))
manifest$seed_pool <- 100000L + seed_index * 1000L
manifest$seed_outer <- 500000L + seed_index * 1000L + manifest$outer_id
manifest$seed_plasmode <- 1000000L + seed_index * 1000L + manifest$outer_id
manifest$seed_final_split <- 1500000L + seed_index * 1000L + manifest$outer_id
manifest$job_index <- seq_len(nrow(manifest))
manifest$job_id <- sprintf("sensitivity-%05d", manifest$job_index)
manifest <- manifest[, c(
  "job_index", "job_id", "experiment", "outer_id", "I", "K", "Gamma", "method",
  "M_values", "eta_true", "eta_work", "effect_id", "seed_pool", "seed_outer",
  "seed_plasmode", "seed_final_split"
)]
dir.create(dirname(output), recursive = TRUE, showWarnings = FALSE)
write.csv(manifest, output, row.names = FALSE)
cat("Wrote", nrow(manifest), "paper-supported sensitivity jobs to", output, "\n")
