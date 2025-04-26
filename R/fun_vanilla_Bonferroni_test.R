# Optimal Sampling
# Algorithm Functions - Vanilla Bonferroni Method

# Bonferroni test functions
#' @export
Bonferroni_test <- function(Gamma, V) {
  
  # arguments:
  # Gamma: design sensitivity - float >= 1
  # V: planning sample - matrix of dimension ((1-xi)*I, K)
  
  # return: 
  # detection_result: whether the outcome is tested to receive the treatment effect or not - vector of dimension K
  # H_order: analysis outcome by decreasing order - logical vector
  # (in only splitting case: the outcome with the largest test value in the planning test)
  
  K = ncol(V)
  I = nrow(V)
  T_value = numeric(K)
  Bonferroni_result = numeric(K)
  
  alpha_p = 0.05 # threshold for planning sample to select variables
  
  K = ncol(V)
  T_value = numeric(K)
  
  # compute the corresponding threshold of the Wilcoxon's test given Gamma for planning set
  kappa = Gamma / (1+Gamma)
  c_p = kappa*I*(I+1) / 2 + qnorm(1-alpha_p/K) * sqrt(kappa*(1-kappa)*I*(I+1)*(2*I+1) / 6)
  
  # compute the Wilcoxon T value for the K outcomes
  for (k in 1:K) {
    T_value[k] = Wilcoxon_test(V[, k])
  }
  
  H_test = (T_value >= c_p)
  detection_result = ifelse(H_test, 1, 0)
  
  return(detection_result)
}
