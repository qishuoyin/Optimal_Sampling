# Optimal Sampling Simulation
# Simulate Sample Dataset

# set relative path
current_dir = getwd()
parent_dir = dirname(getwd())

# set seeds
set.seed(2024) 

# sample simulation function
data_sample_simulation <- function(data_pair_diff, I) {
  
  # arguments:
  # data_pair_diff: entire matched pair difference dataset
  # I: number of outcomes in the simulation sample
  
  # return: 
  # data_pair_sample: sampled matched pair dataset with I units
  
  N = nrow(data_pair_diff)
  index = sample(seq_len(N), size = I)
  data_pair_sample = data_pair_diff[index, ] 
  
  return(data_pair_sample)
}

# generate entire matched pair dataset for desired number of units for simulation
test_sim = 100 # simulation times
I_vec = c(100, 200, 500, 1000) # number of units
K_vec = c(10, 100, 500, 1000) # number of outcomes
Gamma_vec = c(1, 1.25, 1.5, 1.75, 2) # design sensitivity

for(i1 in 1:length(K_vec)) {
  
  K = K_vec[i1]
  
  for(i2 in 1:length(Gamma_vec)) {
    
    Gamma = Gamma_vec[i2]
    
    for(i3 in 1:length(I_vec)) {
      
      I = I_vec[i3]
      
      for(t in 1:test_sim) {
        
        # read dataset
        data_name_diff = paste(c(paste(c("data", "match_diff", "outcome", K, "Gamma", Gamma), collapse="_"), "csv"), collapse=".")
        data_name_control = paste(c(paste(c("data", "match_control", "outcome", K, "Gamma", Gamma), collapse="_"), "csv"), collapse=".")
        data_name_treat = paste(c(paste(c("data", "match_treat", "outcome", K, "Gamma", Gamma), collapse="_"), "csv"), collapse=".")
        
        data_path_diff = paste(c(paste(c(parent_dir, "data_pair"), collapse="/"), data_name_diff), collapse="/")
        data_path_control = paste(c(paste(c(parent_dir, "data_pair"), collapse="/"), data_name_control), collapse="/")
        data_path_treat = paste(c(paste(c(parent_dir, "data_pair"), collapse="/"), data_name_treat), collapse="/")
        
        data_pair_diff = read.csv(data_path_diff)
        data_pair_control = read.csv(data_path_control)
        data_pair_treat = read.csv(data_path_treat)
        
        # simulate sample with outcomes of interest
        data_pair_sample_diff = data_sample_simulation(data_pair_diff, I)
        data_pair_sample_control = data_sample_simulation(data_pair_control, I)
        data_pair_sample_treat = data_sample_simulation(data_pair_treat, I)
        
        # save dataset to csv
        file_name_diff = paste(c(paste(c("data", "simulation_diff", "outcome", K, "Gamma", Gamma, "I", I, "test_sim", t), collapse="_"), "csv"), collapse=".")
        file_name_control = paste(c(paste(c("data", "simulation_control", "outcome", K, "Gamma", Gamma, "I", I, "test_sim", t), collapse="_"), "csv"), collapse=".")
        file_name_treat = paste(c(paste(c("data", "simulation_treat", "outcome", K, "Gamma", Gamma, "I", I, "test_sim", t), collapse="_"), "csv"), collapse=".")
        
        file_path_diff = paste(c(paste(c(parent_dir, "data_simulation"), collapse="/"), file_name_diff), collapse="/")
        file_path_control = paste(c(paste(c(parent_dir, "data_simulation"), collapse="/"), file_name_control), collapse="/")
        file_path_treat = paste(c(paste(c(parent_dir, "data_simulation"), collapse="/"), file_name_treat), collapse="/")
        
        write.csv(data_pair_sample_diff, file_path_diff, row.names = FALSE) # only need to save the dataset once
        write.csv(data_pair_sample_control, file_path_control, row.names = FALSE) # only need to save the dataset once
        write.csv(data_pair_sample_treat, file_path_treat, row.names = FALSE) # only need to save the dataset once
        
        print(paste("K =", K, "; Gamma =", Gamma, "; I = ", I, "; t = ", t, ";"))
        
      }
      
    }
    
  }
  
}





