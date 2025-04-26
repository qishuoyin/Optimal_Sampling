\name{Bonferroni_test}
\alias{Bonferroni_test}
\title{Conduct Bonferroni Correction Test for Matched Outcomes}
\description{
Apply a Bonferroni correction procedure to test each outcome in a matched pair dataset individually. \\
Adjusts the significance level to control the family-wise error rate across multiple outcomes.
}
\usage{
Bonferroni_test(Gamma, V)
}
\arguments{
  \item{Gamma}{design sensitivity - float >= 1.}
  \item{V}{planning sample - matrix of dimension ((1-xi)*I, K).}
}
\value{
  \item{detection_result}{whether the outcome is tested to receive the treatment effect or not - vector of dimension K.}
  \item{H_order}{analysis outcome by decreasing order - logical vector.}
}
\examples{
\dontrun{
library(OptimalSampling)

# example matched dataset
set.seed(123)
V <- matrix(rnorm(500), nrow = 50, ncol = 10)

# apply Bonferroni test
detected_outcomes <- Bonferroni_test(
  Gamma = 1.5,
  V = V
)

print(detected_outcomes)
}
}
