# Optimal Sampling
# Algorithm Functions - Two-Stage Tests

# Part 1: basis functions
# Part 1.1: define sign function
#' @export
sgn <- function(x) {
  if (x>0) {
    sgn = 1
  } else if (x==0) {
    sgn = 1/2
  } else if (x<0) {
    sgn = 0
  }
  return(sgn)
}

# Part 1.2: define Wilcoxon's test function
#' @export
Wilcoxon_test <- function(vec) {
  
  Wilcoxon_t = 0
  for (n in 1:length(vec)) {
    Wilcoxon_t = Wilcoxon_t + sgn(vec[n])*rank(abs(vec))[n]
  }
  
  return(Wilcoxon_t)
  
}

# Part 2: data split
# split data set into planning sample and analysis sample
#' @export
data_split <- function(xi, V) {
  
  # arguments:
  # xi: fraction of analysis sample - float in (0, 1)
  # V: data set - matrix of dimension (I, K)
   
  # returns:
  # V_planning: planning sample - matrix of dimension ((1-xi)*I, K)
  # V_analysis: analysis sample - matrix of dimension (xi*I, K)
  
  I = nrow(V) # data set size
  plan_size = round((1-xi)*I)
  index = sample(seq_len(I), size = plan_size)
  
  V_planning = V[index, ] #as.matrix(V[index, ])
  V_analysis = V[-index, ] #as.matrix(V[-index, ])
  
  return_list = list(V_planning = V_planning, V_analysis = V_analysis)
  return(return_list)
  
}

# Part 3: test functions
# Part 3.1: define planning test
#' @export
planning_test <- function(Gamma, xi, V_planning, method) {
  
  # arguments:
  # Gamma: design sensitivity - float >= 1
  # xi: fraction of analysis sample - float in (0, 1)
  # V_planning: planning sample - matrix of dimension ((1-xi)*I, K)
  # K: number of outcomes - int
  # method: "naive", "select", "rank"
   
  # return: 
  # H_order: analysis outcome by decreasing order - logical vector
  # (in naive split case: the outcome with the largest test value in the planning test)
  
  K = ncol(V_planning)
  I = round(nrow(V_planning) / (1-xi))
  T_planning = numeric(K)
  planning_result = numeric(K)
  
  if (method == "naive") {
    
    # compute Wilcoxon T value for the K outcomes
    for (k in 1:K) {
      T_planning[k] = Wilcoxon_test(V_planning[, k])
    }
    
    H_order = which.max(T_planning)
    
  } else if (method == "select" || method == "rank") {
    
    alpha_p = 0.05 # threshold for planning sample to select variables
    
    K = ncol(V_planning)
    T_planning = numeric(K)
    
    # compute the corresponding threshold of the Wilcoxon's test given Gamma for the planning set
    kappa = Gamma / (1+Gamma)
    c_p = kappa*((1-xi)*I)*((1-xi)*I+1) / 2 + qnorm(1-alpha_p) * sqrt(kappa*(1-kappa)*((1-xi)*I)*((1-xi)*I+1)*(2*(1-xi)*I+1) / 6)
    
    # compute the Wilcoxon T value for the K outcomes
    for (k in 1:K) {
      T_planning[k] = Wilcoxon_test(V_planning[, k])
    }
    
    if (method == "select") {
      
      H_set = which(T_planning >= c_p) # outcomes selected for analysis
      H_order = order(T_planning, decreasing = TRUE)[1: length(H_set)] # outcomes selected for analysis in order by their T values
      
    } else if (method == "rank") {
      
      H_order = order(T_planning, decreasing = TRUE) # outcomes ordered for analysis in order by their T values
      
    }
    
  }
  
  return(H_order)
}

# Part 3.2: define analysis test
#' @export
analysis_test <- function(V_analysis, H_order, method) {
  
  # arguments:
  # V_analysis: analysis sample - matrix of dimension (xi*I, K)
  # H_order: analysis outcome by decreasing order (returned from planning test) - logical vector
  # method: "naive", "select", "rank" - string
   
  # return: 
  # T_hat: T value for analysis sample - vector with the same shape as H_order
  
  if (method == "naive") {
    
    T_hat = Wilcoxon_test(V_analysis[, H_order])
    
  } else if (method == "select" || method == "rank") {
    
    K_h = length(H_order)
    T_hat = numeric(K_h)
    
    for (l in 1:K_h ) {
      h = H_order[l]
      T_hat[l] = Wilcoxon_test(V_analysis[, h])
    }
    
  }
  
  return(T_hat)
}

# Part 4: detection function (detection whether an outcome has a treatment effect)
#' @export
treatment_detection <- function(Gamma, xi, V, method) {
  
  # arguments:
  # Gamma: design sensitivity - float >= 1
  # xi: fraction of analysis sample - float in (0, 1)
  # V: entire sample - matrix of dimension (I, K)
  # K: number of outcomes - int
  # method: "naive", "select", "rank" - string
   
  # returns: 
  # plan_result: selection or rank results from the planning stage - vector of dimension K
  # analysis_result: test results from the analysis stage - vector of dimension K
  
  # define standard deviation in the sample and the significance level for the test
  omega = 1 # standard deviation
  alpha_a = 0.05 # significance level for analysis sample
  kappa = Gamma / (1+Gamma)
  I = nrow(V)
  K = ncol(V)
  
  # split dataset 
  V_split = data_split(xi, V)
  V_planning = V_split$V_planning
  V_analysis = V_split$V_analysis
  
  # compute planning T values to choose the analysis outcome
  H_order = planning_test(Gamma, xi, V_planning, method)
  
  # select outcomes in planning the test
  plan_result = numeric(K)
  plan_result[H_order] = 1
  
  # compute analysis T values based on the planning sample
  T_hat = analysis_test(V_analysis, H_order, method)
  
  # detect outcomes with treatment effect
  analysis_result = numeric(K)
  
  if (method == "naive") {
    
    # compute the corresponding threshold of the Wilcoxon's test given Gamma
    c_a = kappa*(xi*I)*(xi*I+1) / 2 + qnorm(1-alpha_a) * sqrt(kappa*(1-kappa)*(xi*I)*(xi*I+1)*(2*xi*I+1) / 6)
    
    # hypothesis result
    if (T_hat >= c_a) {
      analysis_result[H_order] = 1 # here I suppose once the hypothesis is rejected, then all variables are detected to have treatment effect
    }
    
  } else if (method == "select") {
    
    # compute the corresponding threshold of the Wilcoxon's test given Gamma
    c_a = kappa*(xi*I)*(xi*I+1) / 2 + qnorm(1-alpha_a/length(H_order)) * sqrt(kappa*(1-kappa)*(xi*I)*(xi*I+1)*(2*xi*I+1) / 6)
    analysis_result[H_order[T_hat >= c_a]] = 1
    
  } else if (method == "rank") {
    
    # compute the corresponding threshold of the Wilcoxon's test given Gamma
    alpha_a_vec = alpha_a*(1:length(H_order))/length(H_order)
    c_a_vec = kappa*(xi*I)*(xi*I+1) / 2 + qnorm(1-alpha_a_vec) * sqrt(kappa*(1-kappa)*(xi*I)*(xi*I+1)*(2*xi*I+1) / 6)
    analysis_result[H_order[T_hat >= c_a_vec]] = 1
    
  }
  
  return_list = list(plan_result = plan_result, analysis_result = analysis_result)
  return(return_list)
  
}









