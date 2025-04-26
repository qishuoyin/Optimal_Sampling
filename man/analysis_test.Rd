\name{analysis_test}
\alias{analysis_test}
\title{Conduct Analysis Stage Test on Selected Outcomes}
\description{
Conduct the analysis stage of two-stage sensitivity analysis using the outcomes selected or ranked during the planning stage. \\
Performs hypothesis testing on the analysis sample to detect significant treatment effects.
}
\usage{
analysis_test(V_analysis, H_order, method)
}
\arguments{
  \item{V_analysis}{analysis sample - matrix of dimension (xi*I, K).}
  \item{H_order}{analysis outcome by decreasing order, returned from planning test - logical vector.}
  \item{method}{"naive", "select", "rank" - string.}
}
\value{
  \item{T_hat}{T value on the analysis sample - vector with the same shape as H_order}
}
\examples{
\dontrun{
library(OptimalSampling)

# example analysis sample and selected outcomes
set.seed(123)
V_analysis <- matrix(rnorm(300), nrow = 30, ncol = 10)
H_order <- sample(1:10, 5)

# perform analysis test
detected <- analysis_test(
  V_analysis = V_analysis,
  H_order = H_order,
  method = "rank"
)

print(detected)
}
}
