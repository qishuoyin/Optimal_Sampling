# Optimal Sampling
# Algorithm Functions - Power Evaluation

evaluation <- function(effect_vec, analysis_result) {
  
  # arguments: 
  # effect_vec: vector of ground truth treatment effect
  # analysis_result: matrix of analysis test results
  
  # return:
  # test_power: test power at each split fraction
  effect_index = which(effect_vec > 0)
  test_power = sum(analysis_result[effect_index]) / (nrow(analysis_result)*length(effect_index))
  return(test_power)
  
}



optimal_solution <- function(evaluation_vec, err_tolerant=0.05){
  
  # arguments: 
  # evaluation_vec: vector of test power at each split fraction
  # err_tolerant: max error could tolerant for maximum power in split fraction selection (default: 0.05)
  
  # return: 
  # max_power: maximum power among various split fraction
  # fraction_lower: lower bound of optimal split fraction
  # fraction_upper: upper bound of optimal split fraction
  # worst_power_ratio: ratio of worst case test power vs. optimal test power
  
  # search for max power and its interval
  max_power = max(evaluation_vec) 
  idx_interval = which(evaluation_vec >= (1 - err_tolerant)*max_power)
  idx_lower = idx_interval[1]
  idx_upper = idx_interval[length(idx_interval)]
  fraction_lower = xi_vec[idx_lower] 
  fraction_upper = xi_vec[idx_upper] 
  
  # min power and its sensitivity analysis
  min_power = min(evaluation_vec)
  # worst_power_ratio = min_power / max_power
  
  # return_list = list(max_power = max_power, fraction_lower = fraction_lower, fraction_upper = fraction_upper, worst_power_ratio = worst_power_ratio)
  return_list = list(max_power = max_power, fraction_lower = fraction_lower, fraction_upper = fraction_upper)
  return(return_list)
  
}


