# Find the path of working directory
getwd()

# Set the path of working directory to Cardiohealthpython
setwd("C:\\Users\\User\\OneDrive\\Documents\\Cardiohealthpython")

dir()

# Load necessary libraries
library(dplyr)
library(ggplot2)
library(stats)


# Unmask packages
stats::filter
stats::lag
base::intersect
base::setdiff
base::setequal 
base::union

conflicts()

cvd_dataset <- read.csv("updated_cardio_health_multi1.csv") 

head(cvd_dataset)


# Create a data frame from cvd_dataset
df <- data.frame(cvd_dataset)

# 1. Do CVD patients and people without CVD differ in their lifestyle habits (smoking, drinking, activity), glucose levels, and cholesterol levels?

#   a. Smoking
table(df$cardio_condition, df$smoker) 
chisq.test(table(df$cardio_condition, df$smoker)) 

#   b. Drinking
table(df$cardio_condition, df$alcohol) 
chisq.test(table(df$cardio_condition, df$alcohol)) 

#   c. Activity
table(df$cardio_condition, df$active) 
chisq.test(table(df$cardio_condition, df$active)) 

#   d. Glucose Levels
table(df$cardio_condition, df$glucose_levels) 
chisq.test(table(df$cardio_condition, df$glucose_levels)) 

#   e. Cholesterol Levels
table(df$cardio_condition, df$cholesterol_levels) 
chisq.test(table(df$cardio_condition, df$cholesterol_levels)) 

# 2. Is there is a significant difference between the lifestyle habits?

#   a. Smoking vs. Drinking
table(df$smoker, df$alcohol) 
chisq.test(table(df$smoker, df$alcohol)) 

#   b. Smoking vs. Activity
table(df$smoker, df$active) 
chisq.test(table(df$smoker, df$active)) 

#   c. Drinking vs. Activity
table(df$alcohol, df$active) 
chisq.test(table(df$alcohol, df$active)) 


# 3. Do CVD patients differ in body_mass_index to people without CVD?

t.test(body_mass_index ~ cardio_condition, data = df) 

# Visualizations
# Create boxplots for body_mass_index vs cardio_condition
ggplot(df, aes(x = cardio_condition, y = body_mass_index, fill = cardio_condition)) + 
  geom_boxplot() + 
  labs(title = "BMI by CVD Status", x = "Presence of CVD", y = "Body Mass Index")

# Create bar plots for categorical variables (cardio_condition vs smoker)
ggplot(df, aes(x = cardio_condition, fill = smoker)) + 
  geom_bar(position = "fill") + 
  labs(title = "Smoking by CVD Status", x = "Presence of CVD", y = "Proportion", fill = "Smoker") 

# Create bar plots for categorical variables (cardio_condition vs alcohol)
ggplot(df, aes(x = cardio_condition, fill = alcohol)) + 
  geom_bar(position = "fill") + 
  labs(title = "Alcohol Consumption by CVD Status", x = "Presence of CVD", y = "Proportion", fill = "Alcohol") 

# Create bar plots for categorical variables (cardio_condition vs active)
ggplot(df, aes(x = cardio_condition, fill = active)) + 
  geom_bar(position = "fill") + 
  labs(title = "Physical Activity by CVD Status", x = "Presence of CVD", y = "Proportion", fill = "Physical Activity") 

# Interpretation
# p-valueless than 0.05 indicates statistically significant difference between the groups.