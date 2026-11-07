#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 2L) stop("usage: build_artifacts.R INPUT_DIR OUTPUT_DIR")
input_dir <- normalizePath(args[[1L]], mustWork = TRUE)
paths <- list.files(input_dir, pattern = "^sensitivity-.*[.]rds$", full.names = TRUE)
output_dir <- normalizePath(args[[2L]], mustWork = FALSE)
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

summary_path <- file.path(input_dir, "exp3-sensitivity-summary.csv")
if (file.exists(summary_path)) {
  summary <- read.csv(summary_path, stringsAsFactors = FALSE, check.names = FALSE)
} else {
  if (!length(paths)) stop("no sensitivity result files or migrated summary found")
  rows <- lapply(paths, function(path) {
    object <- readRDS(path)
    cbind(object$job[rep(1L, nrow(object$selections)), , drop = FALSE], object$selections)
  })
  data <- do.call(rbind, rows)
  if (anyDuplicated(data[c("job_id", "M")])) stop("duplicate sensitivity job/M results")
  groups <- split(seq_len(nrow(data)), interaction(
    data$experiment, data$I, data$K, data$Gamma, data$method, data$M,
    data$eta_true, data$eta_work, data$effect_id, drop = TRUE, lex.order = TRUE
  ))
  summary <- do.call(rbind, lapply(groups, function(index) {
    first <- data[index[[1L]], c("experiment", "I", "K", "Gamma", "method", "M",
                                "eta_true", "eta_work", "effect_id"), drop = FALSE]
    summarize <- function(x) {
      margin <- if (length(x) > 1L) stats::qt(.975, length(x) - 1L) * stats::sd(x) / sqrt(length(x)) else NA_real_
      c(mean = mean(x), lower = max(0, mean(x) - margin), upper = min(1, mean(x) + margin))
    }
    for (name in c("power_mean", "zeta_star")) {
      value <- summarize(data[[name]][index])
      prefix <- if (name == "power_mean") "power" else name
      first[[paste0(prefix, "_mean")]] <- value[["mean"]]
      first[[paste0(prefix, "_lower")]] <- value[["lower"]]
      first[[paste0(prefix, "_upper")]] <- value[["upper"]]
    }
    first$n_outer <- length(index)
    first
  }))
}
expected <- c(
  plasmode_count = 90L, affected_proportion = 66L,
  effect_specification = 48L, fixed_affected_count = 6L
)
actual <- table(factor(summary$experiment, levels = names(expected)))
if (!all(as.integer(actual) == unname(expected)) ||
    any(summary$n_outer != 30L) ||
    anyDuplicated(summary[c(
      "experiment", "I", "K", "Gamma", "method", "M",
      "eta_true", "eta_work", "effect_id"
    )])) {
  stop("sensitivity summary is incomplete or contains duplicate paper cells")
}
write.csv(summary, file.path(output_dir, "exp3-sensitivity-summary.csv"), row.names = FALSE)
for (experiment in unique(summary$experiment)) {
  write.csv(summary[summary$experiment == experiment, ],
            file.path(output_dir, paste0(experiment, ".csv")), row.names = FALSE)
}

plasmode <- summary[summary$experiment == "plasmode_count", ]
affected <- summary[summary$experiment == "affected_proportion", ]
effects <- rbind(
  summary[summary$experiment == "effect_specification", ],
  plasmode[plasmode$I == 200L & plasmode$K %in% c(100L, 1000L) & plasmode$M == 250L, ]
)
write.csv(plasmode, file.path(output_dir, "supplement-table-s2.csv"), row.names = FALSE)
write.csv(affected, file.path(output_dir, "supplement-table-s3.csv"), row.names = FALSE)
write.csv(effects, file.path(output_dir, "supplement-table-s4.csv"), row.names = FALSE)

fixed_table <- rbind(
  summary[summary$experiment == "affected_proportion" & summary$I == 200L &
            summary$K == 500L & summary$eta_true == 0.10 & summary$eta_work == 0.10, ],
  summary[summary$experiment == "fixed_affected_count", ]
)
fixed_figure <- rbind(
  fixed_table,
  summary[summary$experiment == "plasmode_count" & summary$I == 200L &
            summary$K == 1000L & summary$M == 250L, ]
)
write.csv(fixed_table, file.path(output_dir, "supplement-table-s8.csv"), row.names = FALSE)
write.csv(fixed_figure, file.path(output_dir, "supplement-figure-s5-data.csv"), row.names = FALSE)

draw_panels <- function(data, x, panels, path, x_label) {
  png(path, width = 1600, height = 900, res = 140)
  on.exit(dev.off(), add = TRUE)
  par(mfrow = c(2, length(panels)), mar = c(4, 4, 2, 1))
  colors <- c(select = "#0072B2", rank = "#D55E00")
  for (metric in c("power_mean", "zeta_star_mean")) for (panel in panels) {
    part <- data[panel$keep(data), , drop = FALSE]
    plot(range(part[[x]]), c(0, 1), type = "n", xlab = x_label,
         ylab = if (metric == "power_mean") "Mean power" else "Mean analysis fraction",
         main = panel$label)
    for (method in c("select", "rank")) for (Gamma in sort(unique(part$Gamma))) {
      curve <- part[part$method == method & part$Gamma == Gamma, , drop = FALSE]
      curve <- curve[order(curve[[x]]), ]
      lines(curve[[x]], curve[[metric]], type = "b", col = colors[[method]],
            lty = match(Gamma, sort(unique(part$Gamma))), pch = if (method == "select") 16 else 17)
    }
  }
}

draw_panels(
  plasmode, "M",
  list(
    list(label = "I=200, K=100", keep = function(d) d$I == 200 & d$K == 100),
    list(label = "I=200, K=1000", keep = function(d) d$I == 200 & d$K == 1000),
    list(label = "I=500, K=500", keep = function(d) d$I == 500 & d$K == 500)
  ), file.path(output_dir, "supplement-figure-s1.png"), "Number of plasmodes"
)

eta_panels <- lapply(sort(unique(affected$eta_true)), function(value) {
  list(label = paste("True proportion", value),
       keep = local({ target <- value; function(d) d$eta_true == target }))
})
draw_panels(affected, "eta_work", eta_panels,
            file.path(output_dir, "supplement-figure-s2.png"), "Working affected proportion")

effects$effect_order <- match(effects$effect_id, c(
  "uniform_small_scaled", "truncnorm_small_scaled", "constant_small_scaled",
  "uniform_moderate_scaled", "constant_small_unscaled"
))
draw_panels(
  effects, "effect_order",
  list(
    list(label = "I=200, K=100", keep = function(d) d$K == 100),
    list(label = "I=200, K=1000", keep = function(d) d$K == 1000)
  ), file.path(output_dir, "supplement-figure-s3.png"), "Effect specification"
)

fixed_figure$configuration <- match(
  paste(fixed_figure$K, fixed_figure$eta_true),
  c("500 0.1", "1000 0.05", "1000 0.1")
)
draw_panels(
  fixed_figure, "configuration",
  list(
    list(label = "Gamma=1", keep = function(d) d$Gamma == 1),
    list(label = "Gamma=1.5", keep = function(d) d$Gamma == 1.5),
    list(label = "Gamma=2", keep = function(d) d$Gamma == 2)
  ), file.path(output_dir, "supplement-figure-s5.png"), "Configuration"
)
cat("Built Experiment 3 sensitivity tables in", output_dir, "\n")
