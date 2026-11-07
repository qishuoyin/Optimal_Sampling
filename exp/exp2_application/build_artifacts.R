#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 2L) stop("usage: build_artifacts.R RESULT_RDS OUTPUT_DIR")
script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script_path <- if (length(script_arg)) sub("^--file=", "", script_arg[[1L]]) else getwd()
experiment_dir <- normalizePath(dirname(script_path), mustWork = TRUE)
result <- readRDS(args[[1L]])
output_dir <- normalizePath(args[[2L]], mustWork = FALSE)
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
optimal <- as.data.frame(result$optimal)
bonferroni <- as.data.frame(result$Bonferroni)
combined <- optimal
for (name in names(combined)) {
  combined[[name]] <- ifelse(optimal[[name]] != 0,
                             ifelse(bonferroni[[name]] != 0, "1*", "1"), "0")
}
combined <- cbind(Gamma = result$Gamma, combined)
write.csv(combined[, c("Gamma", names(combined)[2:45])],
          file.path(output_dir, "main-table-2.csv"), row.names = FALSE)
write.csv(combined[, c("Gamma", names(combined)[46:ncol(combined)])],
          file.path(output_dir, "main-table-3.csv"), row.names = FALSE)

if (!requireNamespace("ggplot2", quietly = TRUE) ||
    !requireNamespace("reshape2", quietly = TRUE)) {
  stop("ggplot2 and reshape2 are required to build supplement Figure S6")
}
application <- read.csv(file.path(experiment_dir, "data_full_cleaned.csv"))
covariates <- application[, c("INDFMPIR", "DMDHHSIZ", "RIDAGEYR", "HOD050", "TREAT")]
covariates$TREAT <- factor(covariates$TREAT, levels = c(0, 1), labels = c("Low", "High"))
long <- reshape2::melt(
  covariates, id.vars = "TREAT", variable.name = "Covariate", value.name = "Value"
)
labels <- c(
  INDFMPIR = "Poverty", DMDHHSIZ = "Family Size",
  RIDAGEYR = "Age", HOD050 = "Room Number"
)
long$Covariate <- factor(long$Covariate, levels = names(labels), labels = labels)
figure <- ggplot2::ggplot(long, ggplot2::aes(x = TREAT, y = Value, fill = TREAT)) +
  ggplot2::geom_boxplot(alpha = .8, width = .5) +
  ggplot2::geom_jitter(width = .15, alpha = .5, size = 1.2) +
  ggplot2::facet_wrap(~Covariate, scales = "free_y") +
  ggplot2::scale_fill_manual(values = c(Low = "#0072B2", High = "#E69F00")) +
  ggplot2::theme_classic() +
  ggplot2::theme(
    legend.position = "bottom",
    strip.text = ggplot2::element_text(size = 14, face = "bold"),
    axis.text.x = ggplot2::element_text(size = 12),
    axis.text.y = ggplot2::element_text(size = 12),
    panel.grid.major = ggplot2::element_blank(),
    panel.grid.minor = ggplot2::element_blank(),
    plot.background = ggplot2::element_rect(fill = "white", color = NA),
    panel.background = ggplot2::element_rect(fill = "white", color = NA)
  )
ggplot2::ggsave(
  file.path(output_dir, "supplement-figure-s6.png"), figure,
  width = 10, height = 6, dpi = 300, bg = "white"
)
cat("Built Experiment 2 tables and supplement Figure S6 in", output_dir, "\n")
