\name{plasmode_datasets}
\alias{plasmode_datasets}
\title{Generate Plasmode Datasets with Simulated Treatment Effects}
\description{
Generate a specified number of plasmode datasets by introducing treatment effects into a control dataset. \\
A fixed proportion of outcomes are randomly selected to receive nonzero treatment effects, with effect sizes drawn uniformly between user-defined lower and upper bounds. \\
Each simulated dataset is saved separately in the specified output directory for later sensitivity analysis or power evaluation.
}
\usage{
plasmode_datasets(data_control, output_dir, sim_num = 1000, effect_ratio = 0.1, effect_size_lower = 0.05, effect_size_upper = 0.2)
}
\arguments{
  \item{data_control}{dataset of outcomes of control - the plasmode datasets are generated based on this dataset.}
  \item{output_dir}{directory to save the generated plasmode datasets - string.}
  \item{sim_num}{number of plasmode datasets generated -int, default to be 1000.}
  \item{effect_ratio}{ratio of outcomes assumed to be affected by the treatment -float within (0, 1), default to be 0.10.}
  \item{effect_size_lower}{lower bound of generated effect size - float in (0, 1), default to be 0.05.}
  \item{effect_size_upper}{upper bound of generated effect size - float in (0, 1), default to be 0.20.}
}
\value{
  \item{effect_vec}{vector of length K indicating whether the effect is generated}
}
\examples{
\dontrun{
library(OptimalSampling)

data_control = read.csv("Your_data_control_path")
plasmode_dir = "Your_plasmode_save_directory"

# generate plasmode datasets
plasmode_datasets(
  data_control = control_data,
  output_dir = output_dir,
  sim_num = 10,
  effect_ratio = 0.1,
  effect_size_lower = 0.05,
  effect_size_upper = 0.2
)
}
}
