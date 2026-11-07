\name{evaluate_rejections}
\alias{evaluate_rejections}
\alias{summarize_rejections}
\alias{summarize_fraction_grid}
\title{Evaluate rejection decisions and fraction grids}
\usage{
evaluate_rejections(rejected, truth)

summarize_rejections(rejected, truth, conf = 0.95)

summarize_fraction_grid(fraction_results, near_optimal_ratio = 0.95)
}
\arguments{
  \item{rejected}{Logical or zero-one rejection vector or matrix.}
  \item{truth}{Logical vector identifying true alternatives.}
  \item{conf}{Confidence level for Monte Carlo intervals.}
  \item{fraction_results}{Data frame containing \code{zeta} and \code{power}.}
  \item{near_optimal_ratio}{Fraction of maximum power defining the near-optimal set.}
}
\description{Computes power, FPR, FWER, FDP/FDR, and the published fraction-selection rule.}
\value{A data frame or a list containing the selected and near-optimal fraction rows.}
