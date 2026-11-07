# High-level, in-memory experiment interfaces.

#' Run one Experiment 1 simulation cell
#'
#' Applies one published method to a list of matched-difference datasets. The
#' caller controls the RNG stream so a manifest runner can preserve legacy draw
#' order across fractions and sensitivity bounds.
#'
#' @param datasets List of data frames or matrices, one per replication.
#' @param Gamma Sensitivity bound.
#' @param method One of `Bonferroni`, `naive`, `select`, or `rank`.
#' @param truth Logical vector identifying affected outcomes.
#' @param zeta Analysis fraction for split methods; ignored for Bonferroni.
#' @return List with rejection matrix, per-replication metrics, and summary.
#' @export
run_simulation_cell <- function(datasets, Gamma, method, truth, zeta = NA_real_) {
  if (!length(datasets)) stop("datasets cannot be empty")
  method <- as.character(method)
  allowed <- c("Bonferroni", "naive", "select", "rank")
  if (!method %in% allowed) stop("unknown method: ", method)
  K <- ncol(datasets[[1L]])
  if (length(truth) != K) stop("truth length must equal the number of outcomes")
  if (!identical(method, "Bonferroni") &&
      (!is.finite(zeta) || zeta <= 0 || zeta >= 1)) stop("split methods require zeta in (0, 1)")

  rejected <- matrix(FALSE, nrow = length(datasets), ncol = K)
  for (replication in seq_along(datasets)) {
    current <- as.data.frame(datasets[[replication]])
    if (ncol(current) != K) stop("all datasets must have the same number of outcomes")
    rejected[replication, ] <- if (identical(method, "Bonferroni")) {
      as.logical(Bonferroni_test(Gamma, current))
    } else {
      as.logical(treatment_detection(Gamma, zeta, current, method)$analysis_result)
    }
  }
  list(
    rejections = rejected,
    replication_metrics = evaluate_rejections(rejected, truth),
    summary = summarize_rejections(rejected, truth)
  )
}

#' Run one planning-sensitivity cell
#'
#' Generates an in-memory plasmode sequence, selects an analysis fraction, and
#' evaluates that fraction on the supplied matched-difference data.
#'
#' @param data_control Control-response data used for plasmodes.
#' @param data_difference Matched treated-minus-control differences.
#' @param Gamma Sensitivity bound.
#' @param method Legacy paper method (`select` or `rank`).
#' @param M_values Plasmode prefix sizes.
#' @param eta_work Working affected-outcome proportion.
#' @param effect_id Effect specification identifier.
#' @param truth Logical vector for the outer simulated dataset.
#' @param coarse_only Whether to skip the fine-grid refinement.
#' @return Plasmode curves, selected fractions, and final-study metrics.
#' @export
run_sensitivity_cell <- function(data_control, data_difference, Gamma, method,
                                 M_values, eta_work, effect_id, truth,
                                 coarse_only = FALSE, seed_plasmode = NULL,
                                 seed_final_split = NULL) {
  with_seed <- function(seed, expression) {
    if (is.null(seed)) return(eval.parent(substitute(expression)))
    had_seed <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
    if (had_seed) old_seed <- get(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
    on.exit({
      if (had_seed) assign(".Random.seed", old_seed, envir = .GlobalEnv)
      else if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE))
        rm(".Random.seed", envir = .GlobalEnv)
    }, add = TRUE)
    set.seed(as.integer(seed))
    eval.parent(substitute(expression))
  }
  stage <- with_seed(seed_plasmode, {
    plasmodes <- generate_plasmode_sequence(
      data_control, M = max(M_values), eta_work = eta_work, effect_id = effect_id
    )
    search <- search_analysis_fraction(
      plasmodes, Gamma = Gamma, method = method, M_prefixes = M_values,
      coarse_only = coarse_only
    )
    list(plasmodes = plasmodes, search = search)
  })
  search <- stage$search
  rows <- lapply(seq_len(nrow(search$selections)), function(index) {
    selection <- search$selections[index, , drop = FALSE]
    result <- with_seed(seed_final_split, run_simulation_cell(
        list(data_difference), Gamma = Gamma, method = method, truth = truth,
        zeta = selection$zeta_star
      ))
    cbind(selection, result$summary)
  })
  list(curves = search$curves, selections = do.call(rbind, rows))
}
