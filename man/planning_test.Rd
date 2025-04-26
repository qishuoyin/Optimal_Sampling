\name{planning_test}
\alias{planning_test}
\title{Conduct Planning Stage Test for Outcome Selection or Ranking}
\description{
Conduct the planning stage of two-stage sensitivity analysis by selecting or ranking outcomes. \\
Applies a bias sensitivity model to the planning sample and outputs selected outcomes for further testing.
}
\usage{
planning_test(Gamma, xi, V_planning, method)
}
\arguments{
  \item{Gamma}{design sensitivity - float >= 1.}
  \item{xi}{fraction of analysis sample - float within (0, 1).}
  \item{V_planning}{planning sample - matrix of dimension ((1-xi)*I, K).}
  \item{K}{number of outcomes - int.}
  \item{method}{"naive", "select", "rank" - string.}
}
\value{
  \item{H_order}{analysis outcome by decreasing order - logical vector.}
}
\examples{
\dontrun{
library(OptimalSampling)

# example planning sample
set.seed(123)
V_planning <- matrix(rnorm(300), nrow = 30, ncol = 10)

# perform planning test
outcome_order <- planning_test(
  Gamma = 1.5,
  xi = 0.3,
  V_planning = V_planning,
  method = "rank"
)

print(outcome_order)
}
}
