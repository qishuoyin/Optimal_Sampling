\name{data_split}
\alias{data_split}
\title{Split Matched Data into Planning and Analysis Samples}
\description{
Split the matched pair dataset into two disjoint subsets: a planning sample and an analysis sample. \\
The planning sample is used for outcome selection or ranking, while the analysis sample is used for hypothesis testing.
}
\usage{
data_split(xi, V)
}
\arguments{
  \item{xi}{fraction of analysis sample - float within (0, 1).}
  \item{V}{data set - matrix of dimension (I, K).}
}
\value{
  \item{V_planning}{planning sample - matrix of dimension ((1-xi)*I, K)}
  \item{V_analysis}{analysis sample - matrix of dimension (xi*I, K)}
}
\examples{
# split a dataset into planning and analysis samples
set.seed(123)
V <- matrix(rnorm(1000), nrow = 100, ncol = 10)
split_result <- data_split(xi = 0.3, V = V)

# access planning and analysis parts
V_planning <- split_result$V_planning
V_analysis <- split_result$V_analysis
}
