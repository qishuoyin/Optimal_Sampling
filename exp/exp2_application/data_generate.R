# Optimal Sampling
# Application - Generate Plasmode Datasets

# set relative path
current_dir = getwd()
parent_dir = dirname(getwd())
parent_parent_dir = dirname(parent_dir)

# import necessary sources
fun_dir = paste(c(parent_parent_dir, "R"), collapse="/")
source(paste(c(fun_dir, "fun_plasmode_datasets.R"), collapse="/"))

# set seed for the simulation
set.seed(2024)

# import paired control data
data_control = read.csv(paste(c(current_dir, "data_pair_control.csv"), collapse="/"))

# set directory for generated plasmode datasets
plasmode_dir = paste(c(current_dir, "data/data_plasmode"), collapse="/")

# generate plasmode datasets
generate_plasmode = plasmode_datasets(data_control, plasmode_dir, sim_num=1000, effect_ratio=0.1, effect_size_lower=0.05, effect_size_upper=0.2)

