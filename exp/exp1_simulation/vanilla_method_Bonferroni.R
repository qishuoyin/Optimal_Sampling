# Optimal Sampling
# Simulation - vanilla Bonferroni method

# set relative path
current_dir = getwd()
parent_dir = dirname(getwd())
parent_parent_dir = dirname(parent_dir)

# set seeds
set.seed(2024)

# import necessary sources
fun_dir = paste(c(parent_parent_dir, "fun"), collapse="/")
source(paste(c(fun_dir, "fun_vanilla_Bonferroni_test.R"), collapse="/"))
source(paste(c(fun_dir, "fun_power_evaluation.R"), collapse="/"))


# Conduct simulation by the vanilla Bonferroni
test_sim = 100 # simulation times
I_vec = c(100, 200, 500, 1000) # number of units
K_vec = c(10, 100, 500, 1000) # number of outcomes
Gamma_vec = c(1, 1.25, 1.5, 1.75, 2) # design sensitivity
method = "vanilla_Bonferroni"


for(i1 in 1:length(K_vec)) {
  
  K = K_vec[i1]
  eta = 0.1 # ratio of affected outcomes
  Kt = round(eta*K) # number of outcomes affected by the treatment
  tau_effect = rep(1, Kt)
  tau_zero = rep(0, K - Kt)
  tau_vec = c(tau_effect, tau_zero) # vector of ground truth treatment effect
  
  for(i2 in 1:length(I_vec)) {
    
    I = I_vec[i2]
    power_mat = matrix(0, nrow = length(Gamma_vec), ncol = 1)
    
    for(i3 in 1:length(Gamma_vec)) {
      
      Gamma = Gamma_vec[i3]
      Bonferroni_result = matrix(0, test_sim, K)
      
      for(t in 1:test_sim) {
        
        # read data set generated before
        sim_info = paste(c("data", "simulation_diff", "outcome", K, "Gamma", Gamma, "I", I, "test_sim", t), collapse="_")
        data_name = paste(c(sim_info, "csv"), collapse=".")
        data_path = paste(c(paste(c(current_dir, "data_simulation"), collapse="/"), data_name), collapse="/")
        V = read.csv(data_path)
        
        test_result = Bonferroni_test(Gamma, V)
        Bonferroni_result[t, ] = test_result
        
      }
      
      file_info = paste(c("outcome", K, "Gamma", Gamma, "I", I, "method", method), collapse="_")
      Bonferroni_file_name = paste(c(paste(c("Bonferroni_test", file_info), collapse="_"), "csv"), collapse=".")
      Bonferroni_file_path = paste(c(paste(c(current_dir, "Bonferroni_test"), collapse="/"), Bonferroni_file_name), collapse="/")
      
      write.csv(Bonferroni_result, Bonferroni_file_path, row.names = FALSE)
      
      print(paste("K =", K, "; Gamma =", Gamma, "; I =", I, "; method =", method))
      
      power = evaluation(tau_vec, Bonferroni_result)
      power_mat[which(Gamma_vec == Gamma)] = power
      
    }
    
    power_file_name = paste(c(paste(c("power", "outcome", K, "I", I, "method", method), collapse="_"), "csv"), collapse=".")
    power_file_path = paste(c(paste(c(current_dir, "Bonferroni_test"), collapse="/"), power_file_name), collapse="/")
    write.csv(power_mat, power_file_path, row.names = FALSE)
    print(paste("K =", K, "; I =", I, "; method =", method))
    
  }
}



