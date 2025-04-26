\name{treatment_detection}
\alias{treatment_detection}
\title{Detect Significant Treatment Effects via Two-Stage Sensitivity Analysis}
\description{
Conduct a full two-stage sensitivity analysis procedure to detect outcomes with significant treatment effects. \\
Splits the data into planning and analysis samples, selects or ranks outcomes in the planning stage, and tests them in the analysis stage.
}
\usage{
treatment_detection(Gamma, xi, V, method)
}
\arguments{
  \item{Gamma}{design sensitivity - float >= 1.}
  \item{xi}{fraction of analysis sample - float within (0, 1).}
  \item{V}{entire sample - matrix of dimension (I, K).}
  \item{K}{number of outcomes - int.}
  \item{method}{"naive", "select", "rank" - string.}
}
\value{
  \item{plan_result}{selection or rank results from the planning stage - vector of dimension K.}
  \item{analysis_result}{test results from the analysis stage - vector of dimension K.}
}
\examples{
\dontrun{
library(OptimalSampling)

# example matched dataset
set.seed(123)
V <- matrix(rnorm(500), nrow = 50, ncol = 10)

# conduct two-stage treatment detection
detected_outcomes <- treatment_detection(
  Gamma = 1.5,
  xi = 0.3,
  V = V,
  method = "rank"
)

print(detected_outcomes)
}
}
