# Optimal Sampling
# Algorithm Functions - Optimal Fraction

# set relative path
current_dir = getwd()
parent_dir = dirname(getwd())
parent_parent_dir = dirname(parent_dir)

# import necessary sources
# source(paste(c(current_dir, "fun_plasmode_datasets.R"), collapse="/"))
# source(paste(c(current_dir, "fun_two_stage_tests.R"), collapse="/"))
# source(paste(c(current_dir, "fun_power_evaluation.R"), collapse="/"))
source(file.path(dirname(sys.frame(1)$ofile), "fun_plasmode_datasets.R"))
source(file.path(dirname(sys.frame(1)$ofile), "fun_two_stage_tests.R"))
source(file.path(dirname(sys.frame(1)$ofile), "fun_power_evaluation.R"))


optimal_fraction <- function(data_control, sim_num, effect_ratio, effect_size_lower, effect_size_upper, Gamma_vec, xi_vec, err_tolerant, method = "rank", plasmode_dir, test_result_dir=NULL, final_result_dir, result_file_name) {
  
  effect_vec = plasmode_datasets(data_control, plasmode_dir, sim_num, effect_ratio, effect_size_lower, effect_size_upper)
  
  print("generate data:")
  
  power_mat = matrix(0, nrow = length(Gamma_vec), ncol = length(xi_vec))
  result_mat = matrix(0, nrow = length(Gamma_vec), ncol = 3)
  rownames(result_mat) = Gamma_vec
  colnames(result_mat) = c("max_power", "fraction_lower", "fraction_upper")
  
  for (Gamma in Gamma_vec) {
    
    for (xi in xi_vec) {
      
      K = ncol(data_control)
      planning_result = data.frame(matrix(0, ncol = K, nrow = sim_num))
      analysis_result = data.frame(matrix(0, ncol = K, nrow = sim_num))
      colnames(planning_result) = colnames(data_control)
      colnames(analysis_result) = colnames(data_control)
      
      for (sim in 1:sim_num) {
        
        # read data set generated before
        data_name = paste(c(paste(c("data_plasmode", sim), collapse="_"), "csv"), collapse=".")
        data_path = paste(c(plasmode_dir, data_name), collapse="/")
        V = read.csv(data_path)
        
        # two-stage tests algorithm
        test_result = treatment_detection(Gamma, xi, V, method)
        select_result = test_result$plan_result
        detect_result = test_result$analysis_result
        planning_result[sim, ] = select_result
        analysis_result[sim, ] = detect_result
        print(paste("method =", method, ";", "Gamma =", Gamma, ";" , "xi =", xi, ";" , "sim =", sim, ";"))
      }
      
      if (!is.null(test_result_dir)) {
        
        # save test results (optional)
        planning_file_name = paste(c(paste(c("planning", "sensivity", Gamma, "fraction", xi, "method", method), collapse="_"), "csv"), collapse=".")
        planning_file_path = paste(c(test_result_dir, planning_file_name), collapse="/")
        write.csv(planning_result, planning_file_path, row.names = FALSE)
        
        analysis_file_name = paste(c(paste(c("analysis", "sensivity", Gamma, "fraction", xi, "method", method), collapse="_"), "csv"), collapse=".")
        analysis_file_path = paste(c(test_result_dir, analysis_file_name), collapse="/")
        write.csv(analysis_result, analysis_file_path, row.names = FALSE)
        
      }
      
      # evaluate power
      power = evaluation(effect_vec, analysis_result)
      power_mat[which(Gamma_vec == Gamma), which(xi_vec == xi)] = power
      
    }
    
    # compute the optimal fraction results set
    evaluation_vec = power_mat[which(Gamma_vec == Gamma), ]
    optimal_fraction_set = optimal_solution(evaluation_vec, err_tolerant)
    max_power = optimal_fraction_set$max_power
    fraction_lower = optimal_fraction_set$fraction_lower
    fraction_upper = optimal_fraction_set$fraction_upper
    
    result_mat[which(Gamma_vec == Gamma), "max_power"] = max_power
    result_mat[which(Gamma_vec == Gamma), "fraction_lower"] = fraction_lower
    result_mat[which(Gamma_vec == Gamma), "fraction_upper"] = fraction_upper
    
  }
  
  if (!is.null(test_result_dir)) {
    
    # save evaluation results (optional)
    power_file_name = paste(c(paste(c("power", "method", method), collapse="_"), "csv"), collapse=".")
    power_file_path = paste(c(test_result_dir, power_file_name), collapse="/") 
    write.csv(power_mat, power_file_path, row.names = FALSE)
    
  }
  
  # save final results (required)
  result_file_path = paste(c(final_result_dir, result_file_name), collapse="/")
  write.csv(result_mat, result_file_path, row.names = FALSE)
  
  return(result_mat)
  
}





