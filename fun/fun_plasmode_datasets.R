# Optimal Sampling
# Algorithm Functions - Plasmode Datasets

plasmode_datasets <- function(data_control, output_dir, sim_num=1000, effect_ratio=0.1, effect_size_lower=0.05, effect_size_upper=0.2) {
  
  # arguments: 
  # data_control: dataset of outcomes for control - the plasmode datasets are generated based on this dataset
  # output_dir: directory to save the generated plasmode datasets - string
  # sim_num: number of plasmode datasets generated -int, default to be 1000
  # effect_ratio: ratio of outcomes assumed to be affected by the treatment -float in (0, 1), default to be 0.1
  # effect_size_lower: lower bound of generated effect size - float in (0, 1), default to be 0.05
  # effect_size_upper: upper bound of generated effect size - float in (0, 1), default to be 0.2
  
  # returns: 
  # effect_vec: vector of length K indicating whether the effect is generated

  
  # sort outcomes assumed to be affected
  col_indices = 1:ncol(data_control)
  treat_indices = sort(sample(col_indices, round(effect_ratio*ncol(data_control)), replace = FALSE), decreasing = FALSE)
  control_indices = setdiff(col_indices, treat_indices)
  
  # generate plasmode datasets for each simulation
  for (sim in 1:sim_num) {
    
    treat_sd = apply(data_control[,treat_indices], 2, sd)
    effect = data.frame(matrix(ncol = ncol(data_control), nrow = nrow(data_control)))
    
    for(i in col_indices) {
      if(i %in% treat_indices) {
        effect[, i] = runif(nrow(data_control), effect_size_lower*treat_sd[which(treat_indices == i)], effect_size_upper*treat_sd[which(treat_indices == i)])
      } else if (i %in% control_indices) {
        effect[, i] = rnorm(nrow(data_control))
      }
    }
    
    data_generate = data_control + effect
    
    file_name = paste(c(paste(c("data_plasmode", sim), collapse="_"), "csv"), collapse=".")
    file_path = paste(c(output_dir, file_name), collapse="/")
    write.csv(data_generate, file_path, row.names = FALSE)
  }
  
  effect_vec = rep(0, ncol(data_control))
  effect_vec[treat_indices] = 1
  effect_vec[control_indices] = 0
  return(effect_vec)
  
}



