# Full-matching conversion used by the simulation and application.

#' Construct treated-control outcome combinations after full matching
#'
#' @param X Observed covariate data frame or matrix.
#' @param Z Binary treatment vector.
#' @param Y Outcome data frame or matrix.
#' @return List of difference, control, and treated outcome data frames.
#' @export
construct_matched_outcomes <- function(X, Z, Y) {
  if (!requireNamespace("MatchIt", quietly = TRUE)) stop("MatchIt is required")
  matching_data <- data.frame(as.data.frame(X), Z = as.numeric(Z))
  match <- MatchIt::matchit(Z ~ ., data = matching_data, method = "full")
  outcomes <- as.data.frame(Y)
  difference <- control <- treated <- list()
  output_index <- 1L
  for (subclass in unique(match$subclass)) {
    indices <- which(match$subclass == subclass)
    treated_indices <- indices[matching_data$Z[indices] == 1]
    control_indices <- indices[matching_data$Z[indices] == 0]
    if (!length(treated_indices) || !length(control_indices)) next
    pairs <- expand.grid(control = control_indices, treated = treated_indices)
    treated_block <- outcomes[pairs$treated, , drop = FALSE]
    control_block <- outcomes[pairs$control, , drop = FALSE]
    difference[[output_index]] <- treated_block - control_block
    control[[output_index]] <- control_block
    treated[[output_index]] <- treated_block
    output_index <- output_index + 1L
  }
  if (!length(difference)) stop("full matching produced no treated-control combinations")
  clean <- function(parts) {
    value <- do.call(rbind, parts)
    row.names(value) <- NULL
    value
  }
  list(
    data_pair_diff = clean(difference),
    data_pair_control = clean(control),
    data_pair_treat = clean(treated)
  )
}

#' Sample a matched-outcome pool
#'
#' @param matched Output from [construct_matched_outcomes()].
#' @param I Number of rows sampled from each component.
#' @return Sampled difference, control, and treated data frames.
#' @export
sample_matched_outcomes <- function(matched, I) {
  sample_one <- function(x) x[sample(seq_len(nrow(x)), I), , drop = FALSE]
  list(
    difference = sample_one(matched$data_pair_diff),
    control = sample_one(matched$data_pair_control),
    treatment = sample_one(matched$data_pair_treat)
  )
}
