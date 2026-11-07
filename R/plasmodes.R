# In-memory plasmode generation and analysis-fraction search.

positive_truncnorm_parameters <- function(target_mean, target_sd) {
  if (target_mean <= 0 || target_sd <= 0) stop("target_mean and target_sd must be positive")
  target_cv <- target_sd / target_mean
  cv_at_alpha <- function(alpha) {
    lambda <- stats::dnorm(alpha) / stats::pnorm(-alpha)
    sqrt(1 + alpha * lambda - lambda^2) / (lambda - alpha)
  }
  alpha <- stats::uniroot(function(value) cv_at_alpha(value) - target_cv, c(-10, 10))$root
  lambda <- stats::dnorm(alpha) / stats::pnorm(-alpha)
  sigma <- target_mean / (lambda - alpha)
  c(mean = -alpha * sigma, sd = sigma)
}

draw_positive_truncnorm <- function(n, target_mean, target_sd) {
  parameters <- positive_truncnorm_parameters(target_mean, target_sd)
  lower <- stats::pnorm(0, mean = parameters[["mean"]], sd = parameters[["sd"]])
  probability <- lower + stats::runif(n) * (1 - lower)
  stats::qnorm(probability, mean = parameters[["mean"]], sd = parameters[["sd"]])
}

plasmode_effect_specification <- function(effect_id) {
  specifications <- list(
    uniform_small_scaled = c("Uniform", "small_0.05_to_0.20", "outcome_sd"),
    truncnorm_small_scaled = c("positive_truncated_Normal", "small_mean_0.125", "outcome_sd"),
    constant_small_scaled = c("constant", "small_0.125", "outcome_sd"),
    uniform_moderate_scaled = c("Uniform", "moderate_0.20_to_0.50", "outcome_sd"),
    constant_small_unscaled = c("constant", "small_0.125", "raw_unscaled")
  )
  value <- specifications[[effect_id]]
  if (is.null(value)) stop("unknown effect_id: ", effect_id)
  data.frame(
    effect_distribution = value[[1L]], effect_magnitude = value[[2L]],
    effect_scaling = value[[3L]], stringsAsFactors = FALSE
  )
}

draw_plasmode_effect <- function(n, sigma, effect_id) {
  if (!is.finite(sigma) || sigma <= 0) stop("outcome standard deviation must be positive")
  switch(
    effect_id,
    uniform_small_scaled = stats::runif(n, 0.05 * sigma, 0.20 * sigma),
    truncnorm_small_scaled = draw_positive_truncnorm(
      n, 0.125 * sigma, (0.20 - 0.05) * sigma / sqrt(12)
    ),
    constant_small_scaled = rep(0.125 * sigma, n),
    uniform_moderate_scaled = stats::runif(n, 0.20 * sigma, 0.50 * sigma),
    constant_small_unscaled = rep(0.125, n),
    stop("unknown effect_id: ", effect_id)
  )
}

#' Generate an in-memory sequence of plasmode datasets
#'
#' This function intentionally retains the published implementation's behavior:
#' one affected-outcome set is sampled and reused across the plasmode sequence.
#'
#' @param data_control Control-response matrix or data frame.
#' @param M Number of plasmodes.
#' @param eta_work Working affected-outcome proportion.
#' @param effect_id Effect specification identifier.
#' @param serialization_digits Optional legacy serialization precision.
#' @return List containing a three-dimensional data array and truth vector.
#' @export
generate_plasmode_sequence <- function(data_control, M, eta_work = 0.10,
                                       effect_id = "uniform_small_scaled",
                                       serialization_digits = NULL) {
  data_control <- as.data.frame(data_control)
  I <- nrow(data_control)
  K <- ncol(data_control)
  if (I < 2L || K < 1L || M < 1L) stop("invalid plasmode dimensions")
  affected_count <- round(eta_work * K)
  if (affected_count < 1L || affected_count > K) stop("eta_work produces an invalid affected count")

  affected <- sort(sample(seq_len(K), affected_count, replace = FALSE))
  sigma <- apply(data_control[, affected, drop = FALSE], 2, stats::sd)
  values <- array(0, c(I, K, M),
                  dimnames = list(NULL, colnames(data_control), paste0("m", seq_len(M))))
  for (m in seq_len(M)) {
    effect <- matrix(0, I, K)
    for (k in seq_len(K)) {
      effect[, k] <- if (k %in% affected) {
        draw_plasmode_effect(I, sigma[[which(affected == k)]], effect_id)
      } else {
        stats::rnorm(I)
      }
    }
    generated <- as.matrix(data_control) + effect
    if (!is.null(serialization_digits)) {
      generated[] <- as.numeric(format(generated, digits = serialization_digits, scientific = FALSE))
    }
    values[, , m] <- generated
  }
  truth <- seq_len(K) %in% affected
  list(values = values, truth = truth, affected = affected,
       eta_work = eta_work, effect_id = effect_id)
}

evaluate_plasmode_fraction <- function(plasmodes, truth, Gamma, zeta, method) {
  M <- dim(plasmodes)[3L]
  true_positive <- numeric(M)
  cumulative_runtime <- numeric(M)
  started <- proc.time()[["elapsed"]]
  for (m in seq_len(M)) {
    detected <- treatment_detection(
      Gamma, zeta, as.data.frame(plasmodes[, , m]), method
    )$analysis_result
    true_positive[[m]] <- sum(detected[truth])
    cumulative_runtime[[m]] <- proc.time()[["elapsed"]] - started
  }
  list(
    true_positive = true_positive,
    cumulative_power = cumsum(true_positive) / (seq_len(M) * sum(truth)),
    cumulative_runtime = cumulative_runtime
  )
}

#' Search for the analysis fraction used by the sensitivity experiment
#'
#' @param plasmode_object Output from [generate_plasmode_sequence()].
#' @param Gamma Sensitivity bound.
#' @param method Legacy paper method (`select` or `rank`).
#' @param M_prefixes Plasmode prefix sizes to summarize.
#' @param coarse_only Whether to use only the 0.05 coarse grid.
#' @return List containing evaluated curves and selected fractions.
#' @export
search_analysis_fraction <- function(plasmode_object, Gamma, method, M_prefixes,
                                     coarse_only = FALSE) {
  M_max <- dim(plasmode_object$values)[3L]
  M_prefixes <- sort(unique(as.integer(M_prefixes)))
  if (any(M_prefixes < 1L | M_prefixes > M_max)) stop("M_prefixes lie outside the sequence")

  coarse <- seq(0.05, 0.95, by = 0.05)
  evaluations <- list()
  evaluate_grid <- function(grid) {
    for (zeta in grid) {
      key <- sprintf("%.2f", zeta)
      if (is.null(evaluations[[key]])) {
        evaluations[[key]] <<- evaluate_plasmode_fraction(
          plasmode_object$values, plasmode_object$truth, Gamma, zeta, method
        )
      }
    }
  }
  evaluate_grid(coarse)

  if (!coarse_only) {
    fine <- numeric()
    for (M in M_prefixes) {
      power <- vapply(sprintf("%.2f", coarse), function(key) {
        evaluations[[key]]$cumulative_power[[M]]
      }, numeric(1))
      qualifying <- coarse[power >= 0.90 * max(power)]
      fine <- union(fine, seq(max(0.01, min(qualifying) - 0.05),
                              min(0.99, max(qualifying) + 0.05), by = 0.01))
    }
    evaluate_grid(sort(setdiff(round(fine, 2), round(coarse, 2))))
  }

  zeta <- sort(as.numeric(names(evaluations)))
  curves <- do.call(rbind, lapply(M_prefixes, function(M) {
    data.frame(
      M = M, zeta = zeta,
      plasmode_power = vapply(sprintf("%.2f", zeta), function(key) {
        evaluations[[key]]$cumulative_power[[M]]
      }, numeric(1)), stringsAsFactors = FALSE
    )
  }))
  selections <- do.call(rbind, lapply(M_prefixes, function(M) {
    current <- curves[curves$M == M, , drop = FALSE]
    selection <- summarize_fraction_grid(
      data.frame(zeta = current$zeta, power = current$plasmode_power)
    )
    data.frame(
      M = M,
      zeta_star = selection$selected$zeta_star,
      zeta_near_lower = selection$selected$zeta_near_lower,
      zeta_near_upper = selection$selected$zeta_near_upper,
      max_plasmode_power = selection$selected$power,
      stringsAsFactors = FALSE
    )
  }))
  list(curves = curves, selections = selections)
}
