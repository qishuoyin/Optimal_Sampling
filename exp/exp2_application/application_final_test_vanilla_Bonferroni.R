# Optimal Sampling
# Application - vanilla Bonferroni method

# set relative path
current_dir = getwd()
parent_dir = dirname(getwd())
parent_parent_dir = dirname(parent_dir)

# set seeds
set.seed(2024)

# import necessary sources
fun_dir = paste(c(parent_parent_dir, "R"), collapse="/")
source(paste(c(fun_dir, "fun_vanilla_Bonferroni_test.R"), collapse="/"))


# input parameters
Gamma_vec = c(1, 1.25, 1.5, 1.75, 2) # different design sensitivity Gamma

# import paired data
data_pair = read.csv(paste(c(current_dir, "data_pair_diff.csv"), collapse="/"))


# test treatment effect by the vanilla Bonferroni
Bonferroni_result = matrix(0, nrow = length(Gamma_vec), ncol = ncol(data_pair))
colnames(Bonferroni_result) = colnames(data_pair)

for (Gamma in Gamma_vec) {
  
  test_result = Bonferroni_test(Gamma, data_pair)
  Bonferroni_result[which(Gamma_vec == Gamma), ] = test_result
  
}

write.csv(Bonferroni_result, paste(c(current_dir, "final_results_vanilla_Bonferroni.csv"), collapse="/"), row.names = FALSE)




