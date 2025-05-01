# Optimal Sampling
# Example Power Plot

# Load necessary library
library(ggplot2)

# Set relative path
current_dir <- getwd()

# Load dataset
data_dir <- file.path(current_dir, "evaluation_result", "example_power_outcome_10_I_200_method_select.csv")

# Read the dataset without header
df <- read.csv(data_dir, header = FALSE, stringsAsFactors = FALSE)

# Extract the second row (since the first row contains column names)
row2 <- as.numeric(as.character(unlist(df[2, -ncol(df)])))

# Remove NA values (caused by non-numeric entries)
row2 <- row2[!is.na(row2)]

# Convert to a dataframe for plotting
row2_df <- data.frame(SplitFraction = seq_along(row2), TestPower = row2)

# Create the plot
p <- ggplot(row2_df, aes(x = SplitFraction, y = TestPower)) +
  geom_line(color = "blue", size = 1) +  # Line plot
  geom_point(color = "red", size = 2) +  # Points for clarity
  theme_classic() +  # Removes grey background
  labs(x = "Split fraction （%）", y = "Test power")  # No title

# Save the plot in the same directory as the R script
save_path <- file.path(current_dir, "example_power_plot_outcome_10_I_200_method_select.png")
ggsave(save_path, plot = p, width = 6, height = 4, dpi = 300)

# Print save path for confirmation
print(paste("Plot saved at:", save_path))
