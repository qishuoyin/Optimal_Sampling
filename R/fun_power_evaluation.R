# Optimal Sampling
# Algorithm Functions - Power Evaluation

evaluation <- function(effect_vec, analysis_result) {
  
  # arguments: 
  # effect_vec: vector of ground truth treatment effect - vector of dimension K
  # analysis_result: matrix of analysis test results - vector of dimension K
  
  # return:
  # test_power: test power at each split fraction - float in (0, 1)

  
  effect_index = which(effect_vec > 0)
  test_power = sum(analysis_result[, effect_index]) / (nrow(analysis_result)*length(effect_index))
  return(test_power)
  
}



optimal_solution <- function(evaluation_vec, err_tolerant=0.05){
  
  # arguments: 
  # evaluation_vec: vector of test power at each split fraction - vector of dimension number of possible split fractions
  # err_tolerant: max error that could be tolerated for maximum power in split fraction selection (default: 0.05)
  
  # return: 
  # max_power: maximum power among various split fractions - float in (0, 1)
  # fraction_lower: lower bound of optimal split fractions - float in (0, 1)
  # fraction_upper: upper bound of optimal split fractions - float in (0, 1)

  
  # search for max power and its interval
  max_power = max(evaluation_vec) 
  idx_interval = which(evaluation_vec >= (1 - err_tolerant)*max_power)
  idx_lower = idx_interval[1]
  idx_upper = idx_interval[length(idx_interval)]
  fraction_lower = xi_vec[idx_lower] 
  fraction_upper = xi_vec[idx_upper]
  return_list = list(max_power = max_power, fraction_lower = fraction_lower, fraction_upper = fraction_upper)
  return(return_list)
  
}


