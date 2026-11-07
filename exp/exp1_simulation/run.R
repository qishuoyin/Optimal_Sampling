#!/usr/bin/env Rscript

script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script_path <- if (length(script_arg)) sub("^--file=", "", script_arg[[1L]]) else getwd()
repo_root <- normalizePath(file.path(dirname(script_path), "../.."), mustWork = TRUE)

args <- commandArgs(trailingOnly = TRUE)
parse_args <- function(x) {
  output <- list()
  while (length(x)) {
    if (!startsWith(x[[1L]], "--") || length(x) < 2L) stop("arguments must be --key value pairs")
    output[[sub("^--", "", x[[1L]])]] <- x[[2L]]
    x <- x[-c(1L, 2L)]
  }
  output
}
args <- parse_args(args)
required <- c("I", "K", "method", "input-dir", "output-dir")
missing <- required[!required %in% names(args)]
if (length(missing)) stop("missing arguments: ", paste(missing, collapse = ", "))

suppressPackageStartupMessages(library(OptimalSampling))
I <- as.integer(args$I)
K <- as.integer(args$K)
method <- args$method
config_table <- read.csv(
  file.path(repo_root, "exp/exp1_simulation/config/paper_grid.csv"),
  stringsAsFactors = FALSE
)
config <- stats::setNames(config_table$values, config_table$parameter)
parse_values <- function(name, mode = c("numeric", "character")) {
  mode <- match.arg(mode)
  value <- strsplit(config[[name]], ";", fixed = TRUE)[[1L]]
  if (mode == "numeric") as.numeric(value) else value
}
if (!I %in% parse_values("I") || !K %in% parse_values("K")) {
  stop("I and K must be values in config/paper_grid.csv")
}
if (!method %in% parse_values("method", "character")) stop("unknown method")
input_dir <- normalizePath(args[["input-dir"]], mustWork = TRUE)
output_dir <- normalizePath(args[["output-dir"]], mustWork = FALSE)
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

Gamma_values <- parse_values("Gamma")
zeta_spec <- as.numeric(strsplit(config[["zeta"]], ":", fixed = TRUE)[[1L]])
zeta_values <- seq(zeta_spec[[1L]], zeta_spec[[2L]], by = zeta_spec[[3L]])
replications <- as.integer(config[["replications"]])
eta_true <- as.numeric(config[["eta_true"]])
seed <- as.integer(config[["seed"]])
truth <- seq_len(K) <= round(eta_true * K)
set.seed(seed)

read_inputs <- function(Gamma) {
  lapply(seq_len(replications), function(replication) {
    path <- file.path(
      input_dir,
      paste0("data_simulation_diff_outcome_", K, "_Gamma_", Gamma,
             "_I_", I, "_test_sim_", replication, ".csv")
    )
    if (!file.exists(path)) stop("missing input: ", path)
    read.csv(path, check.names = FALSE)
  })
}

final_rows <- list()
fraction_rows <- list()
rejections <- list()
for (Gamma in Gamma_values) {
  datasets <- read_inputs(Gamma)
  if (identical(method, "Bonferroni")) {
    result <- run_simulation_cell(datasets, Gamma, method, truth)
    key <- paste(I, K, Gamma, method, sep = "|")
    rejections[[key]] <- result$rejections
    final_rows[[length(final_rows) + 1L]] <- cbind(
      data.frame(I = I, K = K, Gamma = Gamma, method = method,
                 zeta_star = NA_real_, zeta_near_lower = NA_real_,
                 zeta_near_upper = NA_real_, stringsAsFactors = FALSE),
      result$summary
    )
  } else {
    local_rows <- list()
    for (zeta in zeta_values) {
      result <- run_simulation_cell(datasets, Gamma, method, truth, zeta)
      key <- sprintf("%s|%s|%s|%s|%.2f", I, K, Gamma, method, zeta)
      rejections[[key]] <- result$rejections
      local_rows[[length(local_rows) + 1L]] <- cbind(
        data.frame(I = I, K = K, Gamma = Gamma, method = method, zeta = zeta,
                   stringsAsFactors = FALSE), result$summary
      )
    }
    local <- do.call(rbind, local_rows)
    fraction_rows[[length(fraction_rows) + 1L]] <- local
    selection <- summarize_fraction_grid(
      data.frame(zeta = local$zeta, power = local$power_mean)
    )$selected
    selected <- local[local$zeta == selection$zeta_star, , drop = FALSE]
    selected$zeta_star <- selection$zeta_star
    selected$zeta_near_lower <- selection$zeta_near_lower
    selected$zeta_near_upper <- selection$zeta_near_upper
    final_rows[[length(final_rows) + 1L]] <- selected[, c(
      "I", "K", "Gamma", "method", "zeta_star", "zeta_near_lower",
      "zeta_near_upper", names(result$summary)
    )]
  }
}

output <- list(
  final_summary = do.call(rbind, final_rows),
  fraction_summary = if (length(fraction_rows)) do.call(rbind, fraction_rows) else data.frame(),
  rejections = rejections,
  provenance = list(
    generated_utc = format(Sys.time(), tz = "UTC", usetz = TRUE),
    package_version = as.character(packageVersion("OptimalSampling")),
    seed = seed, input_dir = input_dir,
    config = file.path(repo_root, "exp/exp1_simulation/config/paper_grid.csv")
  )
)
saveRDS(output, file.path(output_dir, sprintf("exp1_I%s_K%s_%s.rds", I, K, method)))
write.csv(output$final_summary,
          file.path(output_dir, sprintf("exp1_I%s_K%s_%s_summary.csv", I, K, method)),
          row.names = FALSE)
