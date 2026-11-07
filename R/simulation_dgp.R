# Data-generating process used by the paper simulation.

#' Generate the paper simulation population
#'
#' Retains the data-generating behavior used for the published simulation.
#'
#' @param N Population size.
#' @param K Number of outcomes.
#' @param D Number of observed covariates.
#' @param Gamma Treatment-assignment parameter.
#' @param eta True affected-outcome proportion.
#' @return List containing treatment, covariates, potential outcomes, and observed outcomes.
#' @export
generate_simulation_population <- function(N, K, D, Gamma, eta,
                                           alpha_mean = 1, alpha_sd = 1,
                                           epsilon_mean = 0, epsilon_sd = 1,
                                           tau_mean = 1, tau_sd = 1) {
  if (!requireNamespace("simDAG", quietly = TRUE)) stop("simDAG is required")
  affected_count <- round(eta * K)
  alpha <- matrix(stats::rnorm(D * K, alpha_mean, alpha_sd), D, K)
  epsilon <- matrix(stats::rnorm(N * K, epsilon_mean, epsilon_sd), N, K)
  tau <- stats::rnorm(affected_count, tau_mean, tau_sd)
  treatment <- as.numeric(simDAG::rbernoulli(N, Gamma / (1 + Gamma^2)))
  covariates <- matrix(stats::runif(N * D, 0, 5), N, D)
  unobserved <- stats::rnorm(N)

  control <- matrix(0, N, K)
  treated <- matrix(0, N, K)
  affected <- seq_len(affected_count)
  control[, affected] <- covariates %*% alpha[, affected, drop = FALSE] + epsilon[, affected, drop = FALSE]
  treated[, affected] <- control[, affected, drop = FALSE] +
    matrix(rep(tau, each = N), N, affected_count)
  if (affected_count < K) {
    null <- (affected_count + 1L):K
    control[, null] <- covariates %*% alpha[, null, drop = FALSE] +
      matrix(rep(unobserved, K - affected_count), N, K - affected_count) +
      epsilon[, null, drop = FALSE]
    treated[, null] <- control[, null, drop = FALSE]
  }
  observed <- treated * treatment + control * (1 - treatment)
  colnames(covariates) <- paste0("X", seq_len(D))
  colnames(control) <- paste0("Yc", seq_len(K))
  colnames(treated) <- paste0("Yt", seq_len(K))
  colnames(observed) <- paste0("Y", seq_len(K))
  list(
    Z = treatment, X = covariates, U = unobserved,
    Y_c = control, Y_t = treated, Y = observed,
    truth = seq_len(K) <= affected_count
  )
}
