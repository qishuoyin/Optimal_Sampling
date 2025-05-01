# Optimal Sampling
# Application on NHANES 2017-2018 dataset
# Dataset covariates plots

# Load necessary libraries
library(ggplot2)
library(reshape2)
library(dplyr)

# set relative path
current_dir = getwd()
parent_dir = dirname(getwd())

# Load dataset
data_full_cleaned <- read.csv(paste(c(parent_dir, "data_full_cleaned.csv"), collapse="/"))

# Select relevant columns: keep only "Poverty", "Family Size", "Age", "Room Number", and Treatment
covariates <- c("INDFMPIR", "DMDHHSIZ", "RIDAGEYR", "HOD050", "TREAT")
df <- data_full_cleaned[, covariates]

# Convert treatment to a factor for proper labeling
df$TREAT <- factor(df$TREAT, labels = c("Low", "High"))

# Reshape data for ggplot
df_melted <- melt(df, id.vars = "TREAT", variable.name = "Covariate", value.name = "Value")

# Rename covariates for better readability in the plot
covariate_labels <- c(
  "INDFMPIR" = "Poverty",
  "DMDHHSIZ" = "Family Size",
  "RIDAGEYR" = "Age",
  "HOD050" = "Room Number"
)

# Replace covariate names with readable labels
df_melted$Covariate <- factor(df_melted$Covariate, levels = names(covariate_labels), labels = covariate_labels)

# Define a colorblind-friendly color palette (Blue and Orange)
custom_colors <- scale_fill_manual(values = c("Low" = "#0072B2", "High" = "#E69F00"))

# Generate the box plots (with outliers)
p <- ggplot(df_melted, aes(x = TREAT, y = Value, fill = TREAT)) +
  geom_boxplot(alpha = 0.8, width = 0.5) +  # Include outliers
  geom_jitter(width = 0.15, alpha = 0.5, size = 1.2) +  # Improve jitter visibility
  facet_wrap(~Covariate, scales = "free_y") +  # Separate plots for each covariate
  custom_colors +
  theme_classic() +  # Ensure white background
  theme(
    legend.position = "bottom",
    strip.text = element_text(size = 14, face = "bold"),
    axis.text.x = element_text(size = 12),
    axis.text.y = element_text(size = 12),
    panel.grid.major = element_blank(),  # Remove major grid lines
    panel.grid.minor = element_blank(),  # Remove minor grid lines
    plot.background = element_rect(fill = "white", color = NA),  # Ensure white background
    panel.background = element_rect(fill = "white", color = NA)  # Ensure white panel background
  )

# Save the plot with a white background
ggsave(filename = paste0(current_dir, "/pretreatment_covariates_boxplot.png"), 
       plot = p, width = 10, height = 6, dpi = 300, bg = "white")

# Display the plot
print(p)
