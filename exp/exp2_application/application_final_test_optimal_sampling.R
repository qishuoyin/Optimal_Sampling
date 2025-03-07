# Optimal Sampling
# Application - final test for optimal sampling method

# set relative path
current_dir = getwd()
parent_dir = dirname(getwd())
parent_parent_dir = dirname(parent_dir)

# set seeds
set.seed(2024)

# import necessary sources
fun_dir = paste(c(parent_parent_dir, "fun"), collapse="/")
source(paste(c(fun_dir, "fun_two_stage_tests.R"), collapse="/"))


# input parameters
Gamma_vec = c(1, 1.25, 1.5, 1.75, 2) # different design sensitivity Gamma
xi_vec = seq(from = 0.02, to = 0.98, by = 0.02) # different analysis sample fraction
method = "rank"
optimal_fractions = 0.9 # need to set here


# import paired data
data_pair = read.csv(paste(c(current_dir, "data_pair_diff.csv"), collapse="/"))


final_results = matrix(0, nrow = length(Gamma_vec), ncol = ncol(data_pair))
colnames(final_results) = colnames(data_pair)

for (Gamma in Gamma_vec) {
  
  test_result = treatment_detection(Gamma, xi=optimal_fractions[length(optimal_fractions)], V=data_pair, method)
  select_result = test_result$plan_result
  detect_result = test_result$analysis_result
  final_results[which(Gamma_vec == Gamma), ] = detect_result
  
}

write.csv(final_results, paste(c(current_dir, "final_results.csv"), collapse="/"), row.names = FALSE)





