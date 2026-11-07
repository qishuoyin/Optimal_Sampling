#!/usr/bin/env Rscript

script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script_path <- if (length(script_arg)) sub("^--file=", "", script_arg[[1L]]) else getwd()
experiment_dir <- normalizePath(dirname(script_path), mustWork = TRUE)
source(file.path(experiment_dir, "reference", "published_power.R"))
source(file.path(experiment_dir, "reference", "published_fractions.R"))

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 2L) stop("usage: build_artifacts.R INPUT_DIR OUTPUT_DIR")
input_dir <- normalizePath(args[[1L]], mustWork = TRUE)
output_dir <- normalizePath(args[[2L]], mustWork = FALSE)
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

paths <- list.files(input_dir, pattern = "^exp1_.*[.]rds$", full.names = TRUE)
if (!length(paths)) stop("no Experiment 1 result files found")
objects <- lapply(paths, readRDS)
summary <- do.call(rbind, lapply(objects, `[[`, "final_summary"))
fraction_parts <- lapply(objects, function(x) x$fraction_summary)
fraction_parts <- fraction_parts[vapply(fraction_parts, nrow, integer(1)) > 0L]
fractions <- if (length(fraction_parts)) do.call(rbind, fraction_parts) else data.frame()
key <- c("I", "K", "Gamma", "method")
if (anyDuplicated(summary[key])) stop("duplicate Experiment 1 final cells")
summary <- summary[order(summary$K, summary$I, summary$Gamma, summary$method), ]
required_cells <- 4L * 4L * 5L * 4L
required_fractions <- 4L * 4L * 5L * 3L * 99L
if (nrow(summary) != required_cells || nrow(fractions) != required_fractions) {
  stop(
    "incomplete Experiment 1 results: expected ", required_cells,
    " final cells and ", required_fractions, " fraction cells; found ",
    nrow(summary), " and ", nrow(fractions)
  )
}
write.csv(summary, file.path(output_dir, "exp1_all_metrics.csv"), row.names = FALSE)
write.csv(fractions, file.path(output_dir, "exp1_fraction_metrics.csv"), row.names = FALSE)

# The current paper's power values predate the recoverable rejection-grid evidence.
# Retain them as an explicit compatibility layer and keep fresh-run power separate.
published <- published_power_data()
published_fractions <- published_fraction_data()
paper_results <- merge(
  published, published_fractions,
  by = c("I", "K", "Gamma", "method"), all.x = TRUE, sort = FALSE
)
paper_results <- paper_results[order(
  paper_results$K, paper_results$I, paper_results$Gamma, paper_results$method
), ]
write.csv(paper_results, file.path(output_dir, "paper-published-results.csv"), row.names = FALSE)
write.csv(paper_results[paper_results$K == 1000L, ],
          file.path(output_dir, "main-table-1.csv"), row.names = FALSE)
for (K in c(10L, 100L, 500L)) {
  number <- match(K, c(10L, 100L, 500L)) + 4L
  write.csv(paper_results[paper_results$K == K, ],
            file.path(output_dir, paste0("supplement-table-s", number, ".csv")), row.names = FALSE)
}

method_label <- c(
  Bonferroni = "Bonferroni", naive = "Naive split",
  select = "Optimal Split FWER", rank = "Optimal Split FDR"
)
summary$paper_method <- unname(method_label[summary$method])
error_part <- summary[summary$K == 1000L, c(
  "I", "K", "Gamma", "paper_method", "FPR_mean", "FPR_lower", "FPR_upper",
  "FWER_mean", "FWER_lower", "FWER_upper", "FDR_mean", "FDR_lower", "FDR_upper",
  "mean_rejections", "n_rep"
)]
names(error_part)[names(error_part) == "paper_method"] <- "method"
s1 <- merge(published[published$K == 1000L, c("I", "K", "Gamma", "method", "power")],
            error_part, by = c("I", "K", "Gamma", "method"), all.x = TRUE, sort = FALSE)
write.csv(s1, file.path(output_dir, "supplement-table-s1.csv"), row.names = FALSE)

png(file.path(output_dir, "main-figure-1.png"), width = 1200, height = 800, res = 140)
curve <- fractions[fractions$I == 200L & fractions$K == 10L &
                     fractions$Gamma == 1 & fractions$method == "select", ]
curve <- curve[order(curve$zeta), ]
plot(curve$zeta, curve$power_mean, type = "l", lwd = 2,
     xlab = "Analysis fraction", ylab = "Power", ylim = c(0, max(curve$power_mean)))
dev.off()

png(file.path(output_dir, "supplement-figure-s4.png"), width = 1800, height = 1800, res = 150)
par(mfrow = c(4, 4), mar = c(3, 3, 2, 1))
colors <- c("#000000", "#777777", "#0072B2", "#D55E00")
for (I in sort(unique(published$I))) for (K in sort(unique(published$K))) {
  panel <- published[published$I == I & published$K == K, ]
  plot(c(1, 2), range(panel$power), type = "n", xlab = "Gamma", ylab = "Power",
       main = paste0("I=", I, ", K=", K))
  for (index in seq_along(unique(panel$method))) {
    method <- unique(panel$method)[[index]]
    current <- panel[panel$method == method, ]
    current <- current[order(current$Gamma), ]
    lines(current$Gamma, current$power, type = "b", col = colors[[index]], pch = index)
  }
}
dev.off()

cat("Built Experiment 1 tables in", output_dir, "\n")
