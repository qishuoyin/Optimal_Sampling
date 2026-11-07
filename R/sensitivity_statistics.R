# Sensitivity-statistic helpers. These retain the implementation used for the
# published experiments.

wilcoxon_sensitivity_statistic <- function(x) {
  ranks <- rank(abs(x))
  sum(((x > 0) + 0.5 * (x == 0)) * ranks)
}

sensitivity_critical_value <- function(n, Gamma, alpha) {
  if (n < 1L || Gamma < 1 || alpha <= 0 || alpha >= 1) stop("invalid sensitivity threshold arguments")
  kappa <- Gamma / (1 + Gamma)
  kappa * n * (n + 1) / 2 +
    stats::qnorm(1 - alpha) * sqrt(kappa * (1 - kappa) * n * (n + 1) * (2 * n + 1) / 6)
}
