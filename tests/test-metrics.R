library(OptimalSampling)

truth <- c(TRUE, TRUE, FALSE, FALSE)
rejected <- rbind(
  c(1, 0, 0, 0),
  c(1, 1, 1, 0),
  c(0, 0, 0, 0)
)
metrics <- evaluate_rejections(rejected, truth)
stopifnot(
  identical(metrics$TP, c(1, 2, 0)),
  identical(metrics$FP, c(0, 1, 0)),
  identical(metrics$R, c(1, 3, 0)),
  isTRUE(all.equal(metrics$power, c(.5, 1, 0))),
  isTRUE(all.equal(metrics$FPR, c(0, .5, 0))),
  identical(metrics$FWER, c(0, 1, 0)),
  isTRUE(all.equal(metrics$FDP, c(0, 1 / 3, 0)))
)

summary <- summarize_rejections(rejected, truth)
stopifnot(
  summary$n_rep == 3,
  isTRUE(all.equal(summary$power_mean, .5)),
  isTRUE(all.equal(summary$FPR_mean, 1 / 6)),
  isTRUE(all.equal(summary$FWER_mean, 1 / 3)),
  isTRUE(all.equal(summary$FDR_mean, 1 / 9))
)

grid <- data.frame(zeta = c(.1, .2, .3, .4), power = c(.8, 1, 1, .94))
selected <- summarize_fraction_grid(grid)$selected
stopifnot(
  selected$zeta_star == .2,
  selected$zeta_near_lower == .2,
  selected$zeta_near_upper == .3
)
