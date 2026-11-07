\name{generate_simulation_population}
\alias{generate_simulation_population}
\alias{construct_matched_outcomes}
\alias{sample_matched_outcomes}
\title{Generate and match paper simulation data}
\usage{
generate_simulation_population(N, K, D, Gamma, eta,
  alpha_mean = 1, alpha_sd = 1, epsilon_mean = 0, epsilon_sd = 1,
  tau_mean = 1, tau_sd = 1)

construct_matched_outcomes(X, Z, Y)

sample_matched_outcomes(matched, I)
}
\description{Data-generation and full-matching helpers used by the paper experiments.}
\value{Lists containing generated or matched data.}
\keyword{internal}
