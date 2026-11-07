library(OptimalSampling)

set.seed(2024)
cases <- list(
  rnorm(200),
  sample(c(-2, -1, 0, 1, 2), 200, replace = TRUE),
  rep(0, 50),
  c(-3, -1, 0, 0, 1, 3)
)
for (x in cases) {
  stopifnot(identical(Wilcoxon_test(x), OptimalSampling:::wilcoxon_sensitivity_statistic(x)))
}

evaluation <- c(.4, .8, 1, .96, .3)
zeta <- c(.1, .2, .3, .4, .5)
legacy <- optimal_solution(evaluation, err_tolerant = .05, xi_vec = zeta)
modern <- summarize_fraction_grid(data.frame(zeta = zeta, power = evaluation))$selected
stopifnot(
  legacy$max_power == modern$power,
  legacy$fraction_lower == modern$zeta_near_lower,
  legacy$fraction_upper == modern$zeta_near_upper
)
