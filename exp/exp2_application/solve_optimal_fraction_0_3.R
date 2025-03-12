# Optimal Sampling
# Application - Solve Optimal Split Fraction (generate 30% outcomes affected in plasmode dataset)

# set relative path
current_dir = getwd()
parent_dir = dirname(getwd())
parent_parent_dir = dirname(parent_dir)

# import necessary sources
fun_dir = paste(c(parent_parent_dir, "fun"), collapse="/")
# source(paste(c(fun_dir, "fun_plasmode_datasets.R"), collapse="/"))
# source(paste(c(fun_dir, "fun_two_stage_tests.R"), collapse="/"))
# source(paste(c(fun_dir, "fun_power_evaluation.R"), collapse="/"))
source(paste(c(fun_dir, "fun_optimal_fraction.R"), collapse="/"))

# set parameters
sim_num=1000 # simulation times
effect_ratio=0.3
effect_size_lower=0.05
effect_size_upper=0.2
Gamma_vec = c(1, 1.25, 1.5, 1.75, 2) # different design sensitivity Gamma
xi_vec = seq(from = 0.02, to = 0.98, by = 0.02) # different analysis sample fraction
method = "rank"
plasmode_dir = paste(c(current_dir, "data_plasmode", "data_plasmode_0_3"), collapse="/")
test_result_dir = paste(c(current_dir, "test_results", "test_results_plasmode_0_3"), collapse="/")
final_result_dir = current_dir
result_file_name = paste(c(paste(c("final_result", "method", method, "plasmode_ratio_0_3"), collapse="_"), "csv"), collapse=".")

# solve optimal sample split fraction
data_control = read.csv(paste(c(current_dir, "data_pair_control.csv"), collapse="/"))
result_mat = optimal_fraction(data_control, sim_num, effect_ratio, effect_size_lower, effect_size_upper, Gamma_vec, xi_vec, method = "rank", plasmode_dir, test_result_dir=NULL, final_result_dir, result_file_name)




