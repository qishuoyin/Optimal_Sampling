\name{generate_plasmode_sequence}
\alias{generate_plasmode_sequence}
\alias{search_analysis_fraction}
\title{Generate plasmodes and search analysis fractions}
\usage{
generate_plasmode_sequence(data_control, M, eta_work = 0.1,
  effect_id = "uniform_small_scaled", serialization_digits = NULL)

search_analysis_fraction(plasmode_object, Gamma, method, M_prefixes,
  coarse_only = FALSE)
}
\description{In-memory implementation used by Experiment 3 sensitivity analyses.}
\value{A plasmode object or a list of fraction curves and selections.}
\keyword{internal}
