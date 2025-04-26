\name{evaluation}
\alias{evaluation}
\title{Evaluate Test Power Across Candidate Split Fractions}
\description{
Evaluate the statistical power of two-stage sensitivity tests across different candidate analysis sample split fractions. \\
It compares the detection outcomes from multiple simulations with the ground truth treatment effects to compute power at each candidate split fraction.
}
\usage{
evaluation(effect_vec, analysis_result)
}
\arguments{
  \item{effect_vec}{vector of ground truth treatment effect - vector of dimension K.}
  \item{analysis_result}{matrix of analysis test results - vector of dimension K.}
}
\value{
  \item{test_power}{test power at each split fraction - float within (0, 1).}
}

