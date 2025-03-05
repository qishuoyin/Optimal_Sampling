# Optimal Sampling
# Application on NHANES 2017-2018 dataset
# Dataset outcomes plots

# Load necessary libraries
library(ggplot2)
library(reshape2)
library(dplyr)

# Set relative path
current_dir <- getwd()

# Load dataset
data_pair <- read.csv(paste(c(current_dir, "data_pair_diff.csv"), collapse="/"))

# Reshape data for ggplot
df_melted <- melt(data_pair, variable.name = "outcome", value.name = "treated_minus_control")
# df_melted <- melt(data_pair, variable.name = "Variable", value.name = "Value")

# Generate the box plots with a white background
p <- ggplot(df_melted, aes(x = outcome, y = treated_minus_control)) +
# p <- ggplot(df_melted, aes(x = Variable, y = Value)) +
  geom_boxplot(fill = "#0072B2", alpha = 0.7, outlier.alpha = 0.5) +  # Colorblind-friendly blue
  theme_classic() +  # Ensure white background
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 10),  # Rotate x-axis labels
    strip.text = element_text(size = 12, face = "bold"),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    plot.background = element_rect(fill = "white", color = NA),
    panel.background = element_rect(fill = "white", color = NA)
  )

# Save the plot with a white background
ggsave(filename = paste0(current_dir, "/outcome_boxplot.png"), 
       plot = p, width = 12, height = 6, dpi = 300, bg = "white")

# Display the plot
print(p)
