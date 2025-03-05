# Optimal Sampling
# Application - Solve Optimal Split Fraction (generate 10% outcomes affected in plasmode dataset)

# set relative path
current_dir = getwd()
parent_dir = dirname(getwd())
parent_parent_dir = dirname(parent_dir)

# import necessary sources
fun_dir = paste(c(parent_parent_dir, "fun"), collapse="/")
source(paste(c(fun_dir, "fun_plasmode_datasets.R"), collapse="/"))
source(paste(c(fun_dir, "fun_two_stage_tests.R"), collapse="/"))
source(paste(c(fun_dir, "fun_power_evaluation.R"), collapse="/"))
source(paste(c(fun_dir, "fun_optimal_fraction.R"), collapse="/"))

# intermediate saving directory
# plasmode_dir = paste(c(current_dir, "data_plasmode"), collapse="/")
plasmode_dir_sub_1 = paste(c(current_dir, "data_plasmode", "data_plasmode_0_1"), collapse="/")

# set parameters
simulation = 1000 # simulation times
Gamma_vec = c(1, 1.25, 1.5, 1.75, 2) # different design sensitivity Gamma
xi_vec = seq(from = 0.02, to = 0.98, by = 0.02) # different analysis sample fraction
method = "rank"

power_mat = matrix(0, nrow = length(Gamma_vec), ncol = length(xi_vec))
result_mat = matrix(0, nrow = length(Gamma_vec), ncol = 3)
rownames(result_mat) = Gamma_vec
colnames(result_mat) = c("max_power", "fraction_lower", "fraction_upper")

data_control = read.csv(paste(c(current_dir, "data_pair_control.csv"), collapse="/"))

for (Gamma in Gamma_vec) {
  
  for (xi in xi_vec) {
    
    K = ncol(data_control)
    planning_result = data.frame(matrix(0, ncol = K, nrow = simulation))
    analysis_result = data.frame(matrix(0, ncol = K, nrow = simulation))
    colnames(planning_result) = colnames(data_control)
    colnames(analysis_result) = colnames(data_control)
    
    for (sim in 1:simulation) {
      
      # read data set generated before
      data_name = paste(c(paste(c("data_plasmode", sim), collapse="_"), "csv"), collapse=".")
      data_path = paste(c(plasmode_dir_sub_1, data_name), collapse="/") # INPUT: plasmode_dir_sub_1
      V = read.csv(data_path)
      
      # print("read data")
      
      # two-stage tests algorithm
      test_result = treatment_detection(Gamma, xi, V, method)
      # print("detect effect")
      select_result = test_result$plan_result
      detect_result = test_result$analysis_result
      # print("set detect result")
      planning_result[sim, ] = select_result
      analysis_result[sim, ] = detect_result
      print(paste("method =", method, ";", "Gamma =", Gamma, ";" , "xi =", xi, ";" , "sim =", sim, ";"))
    }
    
    # save test results (optional)
    planning_file_name = paste(c(paste(c("planning", "sensivity", Gamma, "fraction", xi, "method", method), collapse="_"), "csv"), collapse=".")
    planning_file_path = paste(c(paste(c(current_dir, "test_results"), collapse="/"), planning_file_name), collapse="/")
    write.csv(planning_result, planning_file_path, row.names = FALSE) # INPUT: paste(c(current_dir, "test_results"), collapse="/")
    
    analysis_file_name = paste(c(paste(c("analysis", "sensivity", Gamma, "fraction", xi, "method", method), collapse="_"), "csv"), collapse=".")
    analysis_file_path = paste(c(paste(c(current_dir, "test_results"), collapse="/"), analysis_file_name), collapse="/")
    write.csv(analysis_result, analysis_file_path, row.names = FALSE)
    
    # evaluate power
    power = evaluation(planning_result, analysis_result)
    power_mat[which(Gamma_vec == Gamma), which(xi_vec == xi)] = power
    
    # print("save power")
    
  }
  
  # compute the optimal fraction results set
  evaluation_vec = power_mat[which(Gamma_vec == Gamma), ]
  optimal_fraction_set = optimal_fraction(evaluation_vec, err_tolerant=0.05)
  max_power = optimal_fraction_set$max_power
  fraction_lower = optimal_fraction_set$fraction_lower
  fraction_upper = optimal_fraction_set$fraction_upper
  
  result_mat[which(Gamma_vec == Gamma), "max_power"] = max_power
  result_mat[which(Gamma_vec == Gamma), "fraction_lower"] = fraction_lower
  result_mat[which(Gamma_vec == Gamma), "fraction_upper"] = fraction_upper
  
  # print("save result")
  
}

# save evaluation results (optional)
power_file_name = paste(c(paste(c("power", "method", method), collapse="_"), "csv"), collapse=".")
power_file_path = paste(c(paste(c(current_dir, "test_results"), collapse="/"), power_file_name), collapse="/") # INPUT: paste(c(current_dir, "test_results"), collapse="/") 
write.csv(power_mat, power_file_path, row.names = FALSE)

# save final results (required)
result_file_name = paste(c(paste(c("final_result", "method", method), collapse="_"), "csv"), collapse=".")
result_file_path = paste(c(current_dir, result_file_name), collapse="/") # INPUT: current_dir
write.csv(result_mat, result_file_path, row.names = FALSE)





