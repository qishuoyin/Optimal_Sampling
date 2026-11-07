# Metrics shared by the simulation and sensitivity experiments.

#' Evaluate rejection decisions against known truth
#'
#' Computes per-replication power and false-positive summaries from a rejection
#' vector or matrix. Matrix rows are replications and columns are hypotheses.
#'
#' @param rejected Logical or 0/1 vector or matrix of rejection decisions.
#' @param truth Logical or 0/1 vector identifying true alternatives.
#' @return A data frame with one row per replication.
#' @export
evaluate_rejections <- function(rejected, truth) {
  truth <- as.logical(truth)
  if (!length(truth) || anyNA(truth)) stop("truth must be a nonempty vector without NA")

  rejected <- as.matrix(rejected)
  if (ncol(rejected) != length(truth)) {
    stop("rejected columns and truth length must match")
  }
  if (anyNA(rejected) || any(!rejected %in% c(0, 1, FALSE, TRUE))) {
    stop("rejected must contain only 0/1 decisions without NA")
  }
  rejected <- rejected != 0

  n_true <- sum(truth)
  n_null <- sum(!truth)
  true_positive <- if (n_true) rowSums(rejected[, truth, drop = FALSE]) else rep(0, nrow(rejected))
  false_positive <- if (n_null) rowSums(rejected[, !truth, drop = FALSE]) else rep(0, nrow(rejected))
  total <- true_positive + false_positive

  data.frame(
    replication = seq_len(nrow(rejected)),
    TP = true_positive,
    FP = false_positive,
    R = total,
    power = if (n_true) true_positive / n_true else NA_real_,
    FPR = if (n_null) false_positive / n_null else NA_real_,
    FWER = as.numeric(false_positive > 0),
    FDP = false_positive / pmax(total, 1),
    stringsAsFactors = FALSE
  )
}

mean_interval <- function(x, conf = 0.95, bounded = FALSE) {
  x <- x[is.finite(x)]
  if (!length(x)) return(c(mean = NA_real_, lower = NA_real_, upper = NA_real_))
  estimate <- mean(x)
  if (length(x) == 1L) return(c(mean = estimate, lower = NA_real_, upper = NA_real_))
  margin <- stats::qt(1 - (1 - conf) / 2, df = length(x) - 1L) * stats::sd(x) / sqrt(length(x))
  interval <- c(mean = estimate, lower = estimate - margin, upper = estimate + margin)
  if (bounded) interval[c("lower", "upper")] <- pmin(1, pmax(0, interval[c("lower", "upper")]))
  interval
}

#' Summarize a rejection matrix
#'
#' @param rejected Logical or 0/1 rejection matrix.
#' @param truth Logical vector identifying true alternatives.
#' @param conf Confidence level for Monte Carlo intervals.
#' @return One-row data frame containing power and error summaries.
#' @export
summarize_rejections <- function(rejected, truth, conf = 0.95) {
  values <- evaluate_rejections(rejected, truth)
  output <- data.frame(n_rep = nrow(values), stringsAsFactors = FALSE)
  for (metric in c("power", "FPR", "FWER", "FDP")) {
    interval <- mean_interval(values[[metric]], conf = conf, bounded = TRUE)
    name <- if (metric == "FDP") "FDR" else metric
    output[[paste0(name, "_mean")]] <- unname(interval[["mean"]])
    output[[paste0(name, "_lower")]] <- unname(interval[["lower"]])
    output[[paste0(name, "_upper")]] <- unname(interval[["upper"]])
  }
  interval <- mean_interval(values$R, conf = conf, bounded = FALSE)
  output$mean_rejections <- unname(interval[["mean"]])
  output$mean_rejections_lower <- max(0, unname(interval[["lower"]]))
  output$mean_rejections_upper <- unname(interval[["upper"]])
  output
}

#' Select and summarize an analysis-fraction grid
#'
#' The lowest fraction attaining maximum mean power is selected. The near-optimal
#' interval contains fractions with power at least `near_optimal_ratio` times the
#' maximum, matching the paper-result aggregation rule.
#'
#' @param fraction_results Data frame containing `zeta` and `power` columns.
#' @param near_optimal_ratio Ratio defining the near-optimal interval.
#' @return A list containing the selected row and near-optimal rows.
#' @export
summarize_fraction_grid <- function(fraction_results, near_optimal_ratio = 0.95) {
  required <- c("zeta", "power")
  missing <- setdiff(required, names(fraction_results))
  if (length(missing)) stop("fraction_results is missing: ", paste(missing, collapse = ", "))
  if (!nrow(fraction_results) || anyNA(fraction_results[required])) {
    stop("fraction_results must be nonempty and complete")
  }
  if (!is.numeric(near_optimal_ratio) || length(near_optimal_ratio) != 1L ||
      near_optimal_ratio <= 0 || near_optimal_ratio > 1) {
    stop("near_optimal_ratio must lie in (0, 1]")
  }
  ordered <- fraction_results[order(fraction_results$zeta), , drop = FALSE]
  maximum <- max(ordered$power)
  selected <- ordered[which(ordered$power == maximum)[[1L]], , drop = FALSE]
  near <- ordered[ordered$power >= near_optimal_ratio * maximum, , drop = FALSE]
  selected$zeta_star <- selected$zeta
  selected$zeta_near_lower <- min(near$zeta)
  selected$zeta_near_upper <- max(near$zeta)
  list(selected = selected, near_optimal = near)
}
