# Optimal Sampling Simulation
# Simulation: "select" method for simulation plot

# set relative path
current_dir = getwd()
parent_dir = dirname(getwd())
parent_parent_dir = dirname(parent_dir)

# set seeds
set.seed(2024) 

# import necessary sources
fun_dir = paste(c(parent_parent_dir, "fun"), collapse="/")
# source(paste(c(fun_dir, "fun_plasmode_datasets.R"), collapse="/"))
source(paste(c(fun_dir, "fun_two_stage_tests.R"), collapse="/"))
source(paste(c(fun_dir, "fun_power_evaluation.R"), collapse="/"))


# Conduct simulation by the optimal sample split method - "rank"
test_sim = 1000 # simulation times
I_vec = 200 # c(100, 200, 500, 1000) # number of units
K_vec = 10 # c(10, 100, 500, 1000) # number of outcomes
Gamma_vec = c(1, 1.25, 1.5, 1.75, 2) # design sensitivity
xi_vec = seq(from = 0.01, to = 0.99, by = 0.01) # analysis sample fraction
method = "select"


test_result_dir = paste(c(current_dir, "test_results"), collapse="/")
final_result_dir = paste(c(current_dir, "evaluation_result"), collapse="/")


for(i1 in 1:length(K_vec)) {
  
  K = K_vec[i1]
  eta = 0.1 # ratio of affected outcomes
  Kt = round(eta*K) # number of outcomes affected by the treatment
  tau_effect = rep(1, Kt)
  tau_zero = rep(0, K - Kt)
  tau_vec = c(tau_effect, tau_zero) # vector of ground truth treatment effect
  
  for(i2 in 1:length(I_vec)) {
    
    I = I_vec[i2]
    power_mat = matrix(0, nrow = length(Gamma_vec), ncol = length(xi_vec))
    result_mat = matrix(0, nrow = length(Gamma_vec), ncol = 3)
    rownames(result_mat) = Gamma_vec
    colnames(result_mat) = c("max_power", "fraction_lower", "fraction_upper")
    
    for(i3 in 1:length(Gamma_vec)) {
      
      Gamma = Gamma_vec[i3]
      
      for(i4 in 1:length(xi_vec)) {
        
        xi = xi_vec[i4]
        
        planning_result = matrix(0, ncol = K, nrow = test_sim)
        analysis_result = matrix(0, ncol = K, nrow = test_sim)
        
        for(t in 1:test_sim) {
          
          # read data set generated before
          sim_info = paste(c("data", "simulation_diff", "outcome", K, "Gamma", Gamma, "I", I, "test_sim", t), collapse="_")
          data_name = paste(c(sim_info, "csv"), collapse=".")
          data_path = paste(c(paste(c(current_dir, "data_simulation"), collapse="/"), data_name), collapse="/")
          V = read.csv(data_path)
          
          test_result = treatment_detection(Gamma, xi, V, method)
          select_result = test_result$plan_result
          detect_result = test_result$analysis_result
          planning_result[t, ] = select_result
          analysis_result[t, ] = detect_result
          
          print(paste("method =", method, "; K =", K, "; I =", I, "; Gamma =", Gamma, "; xi =", xi, "; sim =", t, ";"))
          
        }
        
        # save test results (optional)
        file_info = paste(c("outcome", K, "Gamma", Gamma, "I", I, "fraction", xi, "method", method), collapse="_")
        planning_file_name = paste(c(paste(c("example", "test_planning", file_info), collapse="_"), "csv"), collapse=".")
        analysis_file_name = paste(c(paste(c("example", "test_analysis", file_info), collapse="_"), "csv"), collapse=".")
        
        planning_file_path = paste(c(test_result_dir, planning_file_name), collapse="/")
        analysis_file_path = paste(c(test_result_dir, analysis_file_name), collapse="/")
        
        write.csv(planning_result, planning_file_path, row.names = FALSE)
        write.csv(analysis_result, analysis_file_path, row.names = FALSE)
        
        
        power = evaluation(tau_vec, analysis_result)
        power_mat[which(Gamma_vec == Gamma), which(xi_vec == xi)] = power
        
      }
      
      # compute the optimal fraction results set
      evaluation_vec = power_mat[which(Gamma_vec == Gamma), ]
      optimal_fraction_set = optimal_solution(evaluation_vec, err_tolerant=0.05)
      max_power = optimal_fraction_set$max_power
      fraction_lower = optimal_fraction_set$fraction_lower
      fraction_upper = optimal_fraction_set$fraction_upper
      
      result_mat[which(Gamma_vec == Gamma), "max_power"] = max_power
      result_mat[which(Gamma_vec == Gamma), "fraction_lower"] = fraction_lower
      result_mat[which(Gamma_vec == Gamma), "fraction_upper"] = fraction_upper
      
      # save an example power file (optional)
      # example_file_name = paste(c(paste(c("example", "power", "outcome", K, "I", I, "method", method), collapse="_"), "csv"), collapse=".")
      # example_file_path = paste(c(current_dir, example_file_name), collapse="/")
      # write.csv(evaluation_vec, example_file_path, row.names = FALSE)
      
    }
    
    # save evaluation results (optional)
    power_file_name = paste(c(paste(c("example", "power", "outcome", K, "I", I, "method", method), collapse="_"), "csv"), collapse=".")
    power_file_path = paste(c(final_result_dir, power_file_name), collapse="/") 
    write.csv(power_mat, power_file_path, row.names = FALSE)
    
    # save final results (required)
    result_file_name = paste(c(paste(c("example", "final_result", "outcome", K, "I", I, "method", method), collapse="_"), "csv"), collapse=".")
    result_file_path = paste(c(final_result_dir, result_file_name), collapse="/")
    write.csv(result_mat, result_file_path, row.names = FALSE)
    
  }
  
}
