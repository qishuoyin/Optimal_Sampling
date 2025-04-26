\name{optimal_fraction}
\alias{optimal_fraction}
\title{Optimal Fraction Computation under Two-Stage Tests}
\description{
Read the dataset generated before.\\
two-stage tests algorithm.\\
save test results (optional).\\
evaluate power.\\
compute the optimal fraction.\\
save evaluation results (optional).\\
save final results (required).
}
\usage{
optimal_fraction(data_control, sim_num, effect_ratio, effect_size_lower, effect_size_upper, Gamma_vec, xi_vec, err_tolerant, method = "rank", plasmode_dir, test_result_dir = NULL, final_result_dir, result_file_name)
}
\arguments{
  \item{data_control}{dataset of outcomes of control - the plasmode datasets are generated based on this dataset.}
  \item{sim_num}{number of plasmode datasets generated - int, default to be 1000.}
  \item{effect_ratio}{ratio of outcomes assumed to be affected by the treatment - float within (0, 1), default to be 0.1.}
  \item{effect_size_lower}{lower bound of generated effect size - float within (0, 1), default to be 0.05.}
  \item{effect_size_upper}{upper bound of generated effect size - float within (0, 1), default to be 0.2.}
  \item{Gamma_vec}{vector of possible design sensitivity - vector of float >= 1.}
  \item{xi_vec}{vector of fraction of analysis sample - vector of float within (0, 1).}
  \item{err_tolerant}{error could be tolerated to solve optimal split fraction solution at max power.}
  \item{method}{"naive", "select", "rank" - string, default to be "rank".}
  \item{plasmode_dir}{directory to save generated plasmode datasets - string.}
  \item{test_result_dir}{optional; directory to save the simulation results by the two-stage tests - string, default to be NULL means not to save them.}
  \item{final_result_dir}{directory to save the final optimal sample split fraction result - string.}
  \item{result_file_name}{file name of the final optimal sample split fraction result - string.}
}
\value{
\code{result_mat}: matrix of the final optimal sample split fraction result.
}
\examples{
\dontrun{
library(OptimalSampling)

# set directory
plasmode_dir = "Your_plasmode_dataset_save_directory"
final_result_dir = "Your_final_result_save_directory"
result_file_name = "Your_final_result_file_name"

# generate datasets
data_control = read.csv("Your_data_control_path")
plasmode_datasets(data_control, plasmode_dir)

# optimal fraction computation
optimal_fraction(
  data_control,
  sim_num = 1000,
  effect_ratio = 0.1,
  effect_size_lower = 0.05,
  effect_size_upper = 0.2,
  Gamma_vec = seq(1, 3, 0.5),
  xi_vec = seq(0.1, 0.9, 0.1),
  err_tolerant = 0.05,
  method = "rank",
  plasmode_dir = plasmode_dir,
  test_result_dir = test_result_dir,
  final_result_dir = final_result_dir,
  result_file_name = "optimal_fraction_result.csv"
)
}
}
