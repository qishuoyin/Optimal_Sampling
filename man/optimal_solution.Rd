\name{optimal_solution}
\alias{optimal_solution}
\title{Find the Optimal Split Fraction Within Tolerated Error}
\description{
Identify the optimal analysis sample split fraction that maximizes the test power. \\
Selects the smallest split fraction achieving power within a specified tolerance of the maximum observed power.
}
\usage{
optimal_solution(evaluation_vec, err_tolerant = 0.05)
}
\arguments{
  \item{evaluation_vec}{vector of test power at each split fraction - vector of dimension number of possible split fractions.}
  \item{err_tolerant}{max error that could be tolerated at maximum power within split fraction selection, default to be 0.05.}
}
\value{
  \item{max_power}{maximum power among various split fractions - float within (0, 1).}
  \item{fraction_lower}{lower bound of optimal split fractions - float within (0, 1).}
  \item{fraction_upper}{upper bound of optimal split fractions - float within (0, 1).}
}
