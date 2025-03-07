# Optimal Sampling
# Application on NHANES 2017-2018 dataset
# full matching on cleaned dataset

# Load necessary libraries
library(foreign)
library(MatchIt)

# set relative path
current_dir = getwd()
parent_dir = dirname(getwd())

# set seed for the simulation
set.seed(2024)

# import paired data
data_full_cleaned = read.csv(paste(c(current_dir, "data_full_cleaned.csv"), collapse="/"))

# full matching on pretreatment variables
full_match <- matchit(TREAT ~ DMDHREDZ + RIAGENDR + RIDRETH1 + INDFMPIR + DMDHHSIZ + RIDAGEYR + HOD050, 
                      data = data_full_cleaned, method = "full")

# convert matching results into pair-matched-difference dataset
for (class in 1:length(full_match$subclass)) {
  class_indices = which(full_match$subclass == class)
  treat_indices = c()
  control_indices = c()
  for (index in class_indices) {
    if (data_full_cleaned$TREAT[index] == 1){
      treat_indices = append(treat_indices, index)
    }else { 
      control_indices = append(control_indices, index)
    }
  }
  
  outcome_names = colnames(data_full_cleaned)[-c(1:9)]
  data_pair_subclass_diff = data.frame((matrix(ncol = length(outcome_names), 
                                               nrow = length(treat_indices) * length(control_indices) )))
  data_pair_subclass_control = data.frame((matrix(ncol = length(outcome_names), 
                                                  nrow = length(treat_indices) * length(control_indices) )))
  data_pair_subclass_treat = data.frame((matrix(ncol = length(outcome_names), 
                                                nrow = length(treat_indices) * length(control_indices) )))
  
  k = 1
  for (i in treat_indices) {
    for (j in control_indices) {
      data_pair_subclass_diff[k, ] = data_full_cleaned[i, -c(1:9)]-data_full_cleaned[j, -c(1:9)]
      data_pair_subclass_control[k, ] = data_full_cleaned[j, -c(1:9)]
      data_pair_subclass_treat[k, ] = data_full_cleaned[i, -c(1:9)]
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

colnames(data_pair_diff) = outcome_names
colnames(data_pair_control) = outcome_names
colnames(data_pair_treat) = outcome_names

# save pair-matched-difference, control, and treat datasets
write.csv(data_pair_diff, paste(c(current_dir, "data_pair_diff.csv"), collapse="/"), row.names = FALSE)
write.csv(data_pair_control, paste(c(current_dir, "data_pair_control.csv"), collapse="/"), row.names = FALSE)
write.csv(data_pair_treat, paste(c(current_dir, "data_pair_treat.csv"), collapse="/"), row.names = FALSE)


