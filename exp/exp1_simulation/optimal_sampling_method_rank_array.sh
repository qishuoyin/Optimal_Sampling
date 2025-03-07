#!/bin/bash
#SBATCH --job-name=optimal_sampling_method_rank_array     # create a short name for your job
#SBATCH --output=slurm-%A.%a.out # stdout file
#SBATCH --error=slurm-%A.%a.err  # stderr file
#SBATCH --nodes=1                # node count
#SBATCH --ntasks=1               # total number of tasks across all nodes
#SBATCH --cpus-per-task=1        # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --mem-per-cpu=4G         # memory per cpu-core (4G is default)
#SBATCH --time=144:00:00          # total run time limit (HH:MM:SS)
#SBATCH --array=1-16              # job array with index values
#SBATCH --mail-type=all          # send email on job start, end and fault
#SBATCH --mail-user=qy1448@princeton.edu

module purge
module load anaconda3/2024.2
conda activate optimal_sampling_env

# Extract the line from parameters.txt based on SLURM_ARRAY_TASK_ID
line=$(sed -n "${SLURM_ARRAY_TASK_ID}p" parameter.txt)

# Split the line into individual parameters
param1=$(echo $line | awk '{print $1}')
param2=$(echo $line | awk '{print $2}')

# Run the R script with the four parameters
Rscript optimal_sampling_method_rank_array.R $param1 $param2 




