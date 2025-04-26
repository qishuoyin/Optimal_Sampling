\name{Wilcoxon_test}
\alias{Wilcoxon_test}
\title{One-Sample Wilcoxon Signed-Rank Test}
\description{
Perform a one-sample Wilcoxon signed-rank test on a numeric vector. \\
Returns the p-value from testing whether the median is zero.
}
\usage{
Wilcoxon_test(vec)
}
\arguments{
  \item{vec}{a numeric vector of matched pair differences.}
}
\value{
A numeric p-value from the one-sided Wilcoxon signed-rank test.
}
\examples{
# perform Wilcoxon test on a sample vector
set.seed(123)
vec <- rnorm(20)
Wilcoxon_test(vec)
}
