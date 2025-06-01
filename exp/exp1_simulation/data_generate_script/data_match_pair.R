# Optimal Sampling Simulation
# Match Dataset to Pairs

# package preparation
library(MatchIt)

# set relative path
current_dir = getwd()
parent_dir = dirname(getwd())

# set seeds
set.seed(2024) 

# (full) matching function 
data_matched_pair <- function(X, Z, Y) {
  
  # arguments:
  # X: covariates 
  # Z: treatment assignment
  # Y: outcomes 
  
  # return: 
  # data_pair_diff: dataset of outcomes into matched pairs
  
  # match the dataset in pairs
  data_full_match = data.frame(cbind(X, Z))
  data_full_outcomes = Y
  # full matching on pretreatment variables
  full_match <- matchit(Z ~ ., data = data_full_match, method = "full")
  
  # convert matching results into pair-matched-difference dataset
  for (class in 1:length(full_match$subclass)) {
    class_indices = which(full_match$subclass == class)
    treat_indices = c()
    control_indices = c()
    for (index in class_indices) {
      if (data_full_match$Z[index] == 1){
        treat_indices = append(treat_indices, index)
      }else { 
        control_indices = append(control_indices, index)
      }
    }
    
    data_pair_subclass_diff = data.frame((matrix(ncol = ncol(data_full_outcomes), 
                                                 nrow = length(treat_indices) * length(control_indices) )))
    data_pair_subclass_control = data.frame((matrix(ncol = ncol(data_full_outcomes), 
                                                    nrow = length(treat_indices) * length(control_indices) )))
    data_pair_subclass_treat = data.frame((matrix(ncol = ncol(data_full_outcomes), 
                                                  nrow = length(treat_indices) * length(control_indices) )))
    
    k = 1
    for (i in treat_indices) {
      for (j in control_indices) {
        data_pair_subclass_diff[k, ] = data_full_outcomes[i, ]-data_full_outcomes[j, ]
        data_pair_subclass_control[k, ] = data_full_outcomes[j, ]
        data_pair_subclass_treat[k, ] = data_full_outcomes[i, ]
        k = k+1
      }
    }
    
    if (class == 1) {
      data_pair_diff = data_pair_subclass_diff
      data_pair_control = data_pair_subclass_control
      data_pair_treat = data_pair_subclass_treat
    } else {
      data_pair_diff = rbind(data_pair_diff, data_pair_subclass_diff)
      data_pair_control = rbind(data_pair_control, data_pair_subclass_control)
      data_pair_treat = rbind(data_pair_treat, data_pair_subclass_treat)
    }
  }
  
  colnames(data_pair_diff) = colnames(Y)
  colnames(data_pair_control) = colnames(Y)
  colnames(data_pair_treat) = colnames(Y)
  
  return_list = list(data_pair_diff = data_pair_diff, 
                     data_pair_control = data_pair_control, 
                     data_pair_treat = data_pair_treat)
  return(return_list)
  
}

# match the dataset into pairs
D = 5 # number of covariates
K_vec = c(10, 100, 500, 1000) # number of outcomes
Gamma_vec = c(1, 1.25, 1.5, 1.75, 2) # design sensitivity

for(i1 in 1:length(K_vec)) {
  
  K = K_vec[i1]
  
  for(i2 in 1:length(Gamma_vec)) {
    
    Gamma = Gamma_vec[i2]
    
    # read data
    data_name = paste(c(paste(c("data", "whole", "outcome", K, "Gamma", Gamma), 
                              collapse="_"), "csv"), collapse=".")
    data_path = paste(c(paste(c(parent_dir, "data_whole"), collapse="/"), data_name), collapse="/")
    data_generate_full = read.csv(data_path) 
    
    # name variables
    X_name_list = NULL
    Y_c_name_list = NULL
    Y_t_name_list = NULL
    Y_name_list = NULL
    
    for (i in 1:D) {
      X_var_name = paste0("X", i)
      X_name_list = c(X_name_list, X_var_name)
    }
    
    for (j in 1:K) {
      Y_c_var_name = paste0("Yc", j)
      Y_t_var_name = paste0("Yt", j)
      Y_var_name = paste0("Y", j)
      Y_c_name_list = c(Y_c_name_list, Y_c_var_name)
      Y_t_name_list = c(Y_t_name_list, Y_t_var_name)
      Y_name_list = c(Y_name_list, Y_var_name)
    }
    
    # initialize variables
    Z = data_generate_full[, "Z"]
    X = data_generate_full[, X_name_list]
    U = data_generate_full[, "U"]
    Y_c = data_generate_full[, Y_c_name_list]
    Y_t = data_generate_full[, Y_t_name_list]
    Y = data_generate_full[, Y_name_list]
    
    # match the dataset into pairs by function
    data_pair_diff = data_matched_pair(X, Z, Y)$data_pair_diff
    data_pair_control = data_matched_pair(X, Z, Y)$data_pair_control
    data_pair_treat = data_matched_pair(X, Z, Y)$data_pair_treat
    
    # save dataset to csv
    file_name_diff = paste(c(paste(c("data", "match_diff", "outcome", K, "Gamma", Gamma), collapse="_"), "csv"), collapse=".")
    file_name_control = paste(c(paste(c("data", "match_control", "outcome", K, "Gamma", Gamma), collapse="_"), "csv"), collapse=".")
    file_name_treat = paste(c(paste(c("data", "match_treat", "outcome", K, "Gamma", Gamma), collapse="_"), "csv"), collapse=".")
    
    file_path_diff = paste(c(paste(c(parent_dir, "data_pair"), collapse="/"), file_name_diff), collapse="/")
    file_path_control = paste(c(paste(c(parent_dir, "data_pair"), collapse="/"), file_name_control), collapse="/")
    file_path_treat = paste(c(paste(c(parent_dir, "data_pair"), collapse="/"), file_name_treat), collapse="/")
    
    write.csv(data_pair_diff, file_path_diff, row.names = FALSE) # only need to save the dataset once
    write.csv(data_pair_control, file_path_control, row.names = FALSE) # only need to save the dataset once
    write.csv(data_pair_treat, file_path_treat, row.names = FALSE) # only need to save the dataset once
    
    print(paste("K =", K, "; Gamma =", Gamma, ";"))
    
  }
  
}


