# Install the R packages the OptimalSampling repository needs (idempotent).
#
# Works two ways:
#   (a) inside the conda env:   conda activate optimal_sampling_env && Rscript install_packages.R
#   (b) with an R module only:  module load R/4.5.1 && Rscript install_packages.R
# Already-installed packages are skipped, so it is safe to re-run.
#
# Experiment 3 requires simDAG for new eta_true settings and MatchIt/optmatch for full
# matching. The remaining packages build the paper figures.

pkgs <- c(
  # data generation and matching
  "MatchIt", "optmatch", "simDAG",
  # visualization
  "ggplot2", "reshape2"
)

repos <- getOption("repos")
if (is.null(repos) || identical(repos[["CRAN"]], "@CRAN@") || is.na(repos[["CRAN"]]))
  repos <- "https://cloud.r-project.org"

for (p in pkgs) {
  if (requireNamespace(p, quietly = TRUE)) {
    message(sprintf("[ok]      %s already installed", p))
  } else {
    message(sprintf("[install] %s ...", p))
    tryCatch(install.packages(p, repos = repos),
             error = function(e) message(sprintf("[FAILED]  %s: %s", p, conditionMessage(e))))
  }
}

installed <- vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)
cat("\n==== dependency status ====\n")
print(data.frame(package = pkgs, installed = installed, row.names = NULL))
if (all(installed)) {
  cat("\nAll dependencies present.\n")
} else {
  cat("\nStill missing:", paste(pkgs[!installed], collapse = ", "), "\n")
  quit(status = 1L)
}
