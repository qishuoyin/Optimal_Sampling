# Optimal Sampling
# Application - Solve Optimal Split Fraction 
# (generate 10% outcomes affected in the plasmode dataset with effect size to be small: 0.05 - 0.20)

# set relative path
current_dir = getwd()
parent_dir = dirname(getwd())
parent_parent_dir = dirname(parent_dir)

# import necessary sources
fun_dir = paste(c(parent_parent_dir, "R"), collapse="/")
source(paste(c(fun_dir, "fun_optimal_fraction.R"), collapse="/"))

# set parameters
sim_num = 1000 # simulation times
effect_ratio = 0.1
effect_size_lower = 0.05
effect_size_upper = 0.20
Gamma_vec = c(1, 1.25, 1.5, 1.75, 2) # different design sensitivity Gamma
xi_vec = seq(from = 0.02, to = 0.98, by = 0.02) # different analysis sample fraction
err_tolerant = 0.01
method = "rank"
plasmode_dir = paste(c(current_dir, "data/data_plasmode"), collapse="/")
final_result_dir = paste(c(current_dir, "fraction_results"), collapse="/")
result_file_name = paste(c(paste(c("final_result", "method", method, "plasmode_ratio_0_1_effect_small"), collapse="_"), "csv"), collapse=".")

# solve optimal sample split fraction
data_control = read.csv(paste(c(current_dir, "data_pair_control.csv"), collapse="/"))
result_mat = optimal_fraction(data_control, sim_num, effect_ratio, effect_size_lower, effect_size_upper, Gamma_vec, xi_vec, err_tolerant, method = "rank", plasmode_dir, test_result_dir=NULL, final_result_dir, result_file_name)

