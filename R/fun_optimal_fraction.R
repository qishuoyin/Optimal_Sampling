# Optimal Sampling
# Algorithm Functions - Optimal Fraction

# set relative path
current_dir = getwd()
parent_dir = dirname(getwd())
parent_parent_dir = dirname(parent_dir)

# import necessary sources (needed when writing code locally but not needed in a R package)
# source(file.path(dirname(sys.frame(1)$ofile), "fun_plasmode_datasets.R"))
# source(file.path(dirname(sys.frame(1)$ofile), "fun_two_stage_tests.R"))
# source(file.path(dirname(sys.frame(1)$ofile), "fun_power_evaluation.R"))


#' @export
optimal_fraction <- function(data_control, sim_num, effect_ratio, effect_size_lower, effect_size_upper, Gamma_vec, xi_vec, err_tolerant, method = "rank", plasmode_dir, test_result_dir=NULL, final_result_dir, result_file_name) {
  
  # arguments: 
  # data_control: dataset of outcomes for control - the plasmode datasets are generated based on this dataset
  # sim_num: number of plasmode datasets generated -int, default to be 1000
  # effect_ratio: ratio of outcomes assumed to be affected by the treatment -float in (0, 1), default to be 0.1
  # effect_size_lower: lower bound of generated effect size - float in (0, 1), default to be 0.05
  # effect_size_upper: upper bound of generated effect size - float in (0, 1), default to be 0.2
  # Gamma_vec: vector of possible design sensitivity - vector of float >= 1
  # xi_vec: vector of fraction of analysis sample - vector of float in (0, 1)
  # err_tolerant: error could be tolerated in optimal split fraction solution for max power
  # method = "naive", "select", "rank" - string, default to be "rank"
  # plasmode_dir: directory to save generated plasmode datasets - string
  # test_result_dir: directory to save the simulation results by the two-stage tests - string, default to be NULL for not to save them
  # final_result_dir: directory to save the final optimal sample split fraction result - string
  # result_file_name: file name of the final optimal sample split fraction result - string

  # return: 
  # result_mat: matrix of the final optimal sample split fraction result

  
  effect_vec = plasmode_datasets(data_control, plasmode_dir, sim_num, effect_ratio, effect_size_lower, effect_size_upper)
  
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
        
        # read the dataset generated before
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
        planning_file_name = paste(c(paste(c("planning", "sensitivity", Gamma, "fraction", xi, "method", method), collapse="_"), "csv"), collapse=".")
        planning_file_path = paste(c(test_result_dir, planning_file_name), collapse="/")
        write.csv(planning_result, planning_file_path, row.names = FALSE)
        
        analysis_file_name = paste(c(paste(c("analysis", "sensitivity", Gamma, "fraction", xi, "method", method), collapse="_"), "csv"), collapse=".")
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





