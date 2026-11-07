\name{run_simulation_cell}
\alias{run_simulation_cell}
\alias{run_sensitivity_cell}
\title{Run in-memory paper experiment cells}
\usage{
run_simulation_cell(datasets, Gamma, method, truth, zeta = NA_real_)

run_sensitivity_cell(data_control, data_difference, Gamma, method,
  M_values, eta_work, effect_id, truth, coarse_only = FALSE,
  seed_plasmode = NULL, seed_final_split = NULL)
}
\description{High-level package interfaces used by the versioned experiment configurations.}
\value{Lists containing rejection metrics or sensitivity curves and selections.}
\keyword{internal}
