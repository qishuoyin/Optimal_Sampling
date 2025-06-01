# Optimal Sampling Simulation
# Entire Dataset Generation

# package preparation
library(simDAG)

# set relative path
current_dir = getwd()
parent_dir = dirname(getwd())

# set seeds
set.seed(2024) 

# data-generating function
data_generate <- function(N, K, D, Gamma, eta, 
                          alpha_mean, alpha_sd, 
                          epsilon_mean, epsilon_sd, 
                          tau_mean, tau_sd) {
  
  # arguments:
  # N: number of units - number
  # K: number of outcomes - number
  # D: number of covariates - number
  # Gamma: design sensitivity - number
  # eta:  ratio of affected outcomes - number
  # alpha_mean: mean of parameter in linear outcome model - number
  # alpha_sd: sd of parameter in linear outcome model - number
  # epsilon_mean: mean of noise in linear outcome model - number
  # epsilon_sd: sd of noise in linear outcome model - number
  # tau_mean: mean of treatment effect - number
  # tau_sd: sd of treatment effect - number
  
  # intermediate variables: 
  # Kt: number of outcomes affected by the treatment
  # alpha: parameter in linear outcome model - D*K matrix
  # epsilon: noise in linear outcome model - I*K matrix
  # tau: treatment effect - 1*Kt matrix 
  # Y_c: outcomes for control
  # Y_t: outcomes for treated
  
  # return: 
  # X: covariates - shape: I*D
  # U: confounders - shape: I*1
  # Z: treatment assignment
  # Y: outcome observed (depends on Z = 0 or 1)
  
  # data-generating model parameters
  Kt = round(eta*K) # number of outcomes affected by the treatment
  alpha = matrix(rnorm(n = D*K, mean = alpha_mean, sd = alpha_sd), nrow = D, ncol = K) # alpha: parameter in linear outcome model - D*K matrix
  epsilon = matrix(rnorm(n = N*K, mean = epsilon_mean, sd = epsilon_sd), nrow = N, ncol = K) # epsilon: noise in linear outcome model - I*K matrix
  tau = matrix(rnorm(n = Kt, mean = tau_mean, sd = tau_sd), nrow = 1, ncol = Kt) # treatment effect - K*D matrix
  
  # generate p
  Z = matrix(as.numeric(rbernoulli(n = N, p = Gamma/(1+Gamma^2))), nrow = N, ncol = 1)
  X = matrix(runif(n = N*D, min = 0, max = 5), nrow = N, ncol = D) # covariates - shape: N*D
  U = matrix(rnorm(n = N, mean = 0, sd = 1), nrow = N, ncol = 1) # confounders - shape: N*1
  
  Y_c = matrix(rep(0, N*D), nrow = N, ncol = K)
  Y_t = matrix(rep(0, N*D), nrow = N, ncol = K)
  # outcomes affected
  Y_c[ , 1:Kt] = X %*% alpha[ , 1:Kt] + epsilon[ , 1:Kt] # outcomes for control - shape: N*Kt
  Y_t[ , 1:Kt] = matrix(rep(tau, N), byrow = TRUE, nrow = N, ncol = Kt) + X %*% alpha[ , 1:Kt] + epsilon[ , 1:Kt] # outcomes for treated - shape: N*Kt
  # outcomes not affected
  Y_c[ , (Kt+1):K] = X %*% alpha[ , (Kt+1):K] + matrix(rep(U, K-Kt), byrow = FALSE, nrow = N, ncol = K-Kt) + epsilon[ , (Kt+1):K] # outcomes for control - shape: N*(K-Kt)
  Y_t[ , (Kt+1):K] = Y_c[ , (Kt+1):K]
  # outcome observed
  Y = Y_t * matrix(rep(Z, D), nrow = N, ncol = K, byrow = FALSE) + Y_c * (1 - matrix(rep(Z, D), nrow = N, ncol = K, byrow = FALSE))
  
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
  
  colnames(U) = "U"
  colnames(Z) = "Z"
  colnames(X) = X_name_list
  colnames(Y_c) = Y_c_name_list
  colnames(Y_t) = Y_t_name_list
  colnames(Y) = Y_name_list
  
  return_list = list(Z = Z, X = X, U = U, Y_c = Y_c, Y_t = Y_t, Y = Y)
  return(return_list)
  
}

# data generating process
# dataset info
N = 5000 # entire generated dataset size
D = 5 # number of covariates
K_vec = c(10, 100, 500, 1000) # number of outcomes
Gamma_vec = c(1, 1.25, 1.5, 1.75, 2) # design sensitivity
eta = 0.1 # ratio of affected outcomes

# model parameter
alpha_mean = 1
alpha_sd = 1
epsilon_mean = 0
epsilon_sd = 1
tau_mean = 1
tau_sd = 1

# generate entire dataset
for (K in K_vec) {
  
  for (Gamma in Gamma_vec) {
    
    data_generate_list = data_generate(N, K, D, Gamma, eta, 
                                       alpha_mean, alpha_sd, 
                                       epsilon_mean, epsilon_sd, 
                                       tau_mean, tau_sd)
    Z = data_generate_list$Z
    X = data_generate_list$X
    U = data_generate_list$U
    Y_c = data_generate_list$Y_c
    Y_t = data_generate_list$Y_t
    Y = data_generate_list$Y
    data_generate_table = cbind(Z, X, U, Y_t, Y_c, Y)
    
    # save dataset to csv
    file_name = paste(c(paste(c("data", "whole", "outcome", K, "Gamma", Gamma), collapse="_"), "csv"), collapse=".")
    file_path = paste(c(paste(c(parent_dir, "data_whole"), collapse="/"), file_name), collapse="/")
    write.csv(data_generate_table, file_path, row.names = FALSE) # only need to save the dataset once
    
    print(paste("K =", K, "; Gamma =", Gamma, ";"))
    
  }
  
}


