# Health Monitoring Data Analysis to Inform Personalized CVD Care
 
## Background
Cardiovascular Disease (CVD) more commonly known as heart disease remains a major global health challenge. At least 20 million people die of CVD each year (WHO, 2021). While many deaths are preventable, progress in reducing these deaths has slowed down in recent times. 
 
## Project Goal
This study aims to better understand the risk factors for heart disease specifically to identify which factors, individually and together, increase the risk of heart disease. This information could potentially inform the use of healthcare data to increase the precision and accuracy of cardiovascular disease prediction. The author analysed data from about 70,000 participants, studying the relationship between factors such as age, gender, blood sugar, cholesterol, weight, and lifestyle habits.

## Statistical Analysis
Statistical analysis was carried our in R to answer the following questions:
1. Do CVD patients and people without CVD differ in their lifestyle habits (smoking, drinking, activity), glucose levels, and cholesterol levels?
2. Do CVD patients differ in Body Mass Index (BMI) from people without CVD?

**Question 1** was tackled using Pearson's Chi-squared test with Yates' continuity correction. While a significantly higher proportion of the population are non-smokers, non-drinkers and physically active, analysis results suggest that that smoking, physical activity levels, glucose levels, and cholesterol levels are significantly associated with the presence of cardiovascular conditions in the dataset.
Alcohol consumption on the other hand may have a weaker or no significant association with cardiovascular conditions based on this analysis.
**Question 2** was tackled using Welch Two Sample t-test. The analysis provides strong evidence that individuals with cardiovascular conditions have a significantly higher mean BMI compared to those without. 

![cvd_stat_visual](https://github.com/user-attachments/assets/88ce4465-1e02-4ad5-849b-97d16b8ddb1e)

## Sample Visuals

### Cardiovascular Disease (CVD) Incidence across different Body Mass Index (BMI) Categories
The first image provides a summary of the data as well as some of the considered parameters in this study. The BMI categories were assigned according to the WHO crude estimate for BMI classification. Participant population was first grouped by the presence of CVD and further grouped by gender. 
The second image shows further exploration of the lifestyle habits, glucose and cholesterol levels of the female population. 
The third image shows identical parameters for the male population. 

https://github.com/user-attachments/assets/fe285644-468a-4d93-8e6f-2d9a95c1b11a

### Lifestyle Habits vs CVD Incidence
The final image is an interactive visual depicting a permutation of lifestyle habits in 8 subplots that can be filtered/sliced to select groups of interest to identify which factors, individually and together, increase the risk of heart disease. 

https://github.com/user-attachments/assets/3a753ed7-e602-471a-aa08-b83b9d4cb7a0

Glucose levels and Cholesterol levels were combined to form 9 categories to create a slicer. The 'lifestyle habits' were also grouped into 8 categories making up the subplots shown (further detail in Multiple_CVD_subplots.ipynb notebook)

##Software Tools
MySQL, Jupyter Notebook, Power BI Desktop, MS PowerPoint and MS Excel

 ### Snippets of SQL Code for Data Preparation
~~~~sql
SELECT *
FROM cardiovascular_incidence
ORDER BY 2;

# Choose more descriptive column names
ALTER TABLE cardiovascular_incidence
	CHANGE COLUMN height height_in_cm
		INT NULL;
			
ALTER TABLE cardiovascular_incidence
	CHANGE COLUMN weight weight_in_kg
		INT NULL;

# Calculate the BMI (add new column body_mass_index)
# Rank the BMI - 1 : underweight, 2 : healthy, 3 : overweight, 4 : obese, 5 : severely obese (add new column bmi_ranking)*/
	
ALTER TABLE cardio_train_incidence
	ADD body_mass_index
		FLOAT Default 0
			AFTER weight_in_kg;
UPDATE cardio_train_incidence
SET
	body_mass_index = IFNULL(weight_in_kg /((height_in_cm/100) * (height_in_cm/100)), 0);

# Having noticed abnormally high body_mass_index, I identified wrong entries in height_in_cm
UPDATE cardio_train_incidence
SET
	height_in_cm = height_in_cm + 100
WHERE height_in_cm < 100;

# Create a new column to compute different permutations of lifestyle habits (smoker, alcohol and active)
ALTER TABLE cardio_train_incidence
	ADD lifestyle_habits
		FLOAT Default 0
			AFTER active;
UPDATE cardio_train_incidence
SET
	lifestyle_habits = 1
WHERE 
	(smoker is False AND alcohol is False AND active is False);
# And so on for the following permitations
# 2 : where smoker is False and alcohol is False and Active is True
# 3 : where smoker is False and alcohol is True and Active is False
# 4 : where smoker is False and alcohol is True and Active is True
# 5 : where smoker is True and alcohol is False and Active is False
# 6 : where smoker is True and alcohol is False and Active is True
# 7 : where smoker is True and alcohol is True and Active is False
# 8 : where smoker is True and alcohol is True and Active is True
~~~~

### Snippets of Python Code for Data Visualisation 

```python
# Bring in packages
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import altair as alt

# Read Queried Data
df = pd.read_csv(r'C:\Users\User\OneDrive\Documents\Cardiohealth\bmi_pop_data.csv') 
print(df.head())

# Boolean Values are still in TINYINT; Convert to True/False
df['cardio_condition'] = df['cardio_condition'].apply(lambda x: True if x == 1 else False)

print(len(df))

# Count the frequency of each BMI classification
bmigendergroup_counts = df.groupby(['bmi_class', 'cardio_condition', 'gender']).size().unstack(['cardio_condition', 'gender'])
bmigroup_counts =df.groupby(['bmi_class', 'cardio_condition']).size().unstack(fill_value=0) 
bmicategory_counts = df['bmi_class'].value_counts()
bmicategory_counts.columns = ['bmi_class', 'frequency']

# Create the bar chart of Frequency against BMI Category
plt.figure(figsize=(8, 6))
bmicategory_counts.plot(kind='bar', color='skyblue')
plt.title('Distribution of BMI Classes')
plt.xlabel('BMI Category')
plt.ylabel('Number of Participants')
plt.show()

# Display the plot
plt.tight_layout()
plt.show()

# Save the plot as a PNG image
plt.savefig('BMIcategory_distribution_bar_chart.png')
```
Python was also used to add the multiple subplots to Power BI. Details of this  can be found in the repository associated with this project. It includes notebooks containing code and visual output.

### Snippets of R code for Analysis
```{r}
# Find the path of working directory
getwd()

# Load necessary libraries
library(dplyr)
library(ggplot2)
library(stats)

# Create a data frame from cvd_dataset
df <- data.frame(cvd_dataset)

# 1. Do CVD patients and people without CVD differ in their lifestyle habits (smoking, drinking, activity), glucose levels, and cholesterol levels?

#   a. Smoking
table(df$cardio_condition, df$smoker) 
chisq.test(table(df$cardio_condition, df$smoker)) 

#   b. Alcohol Consumption
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
foo()
``` 
## Challenges Encountered
1. Most of the data used was categorical: Smoker, active and alcohol consumption were all boolean data type even though it is unclear what the threshold for an active lifestyle is for instance.
2. There was no detail about CVD types: CVDs comprise a broad range of disease that are often influenced in different was by the factors studied. Knowing what types of CVD participants were living with would most likely reduce result ambiguity.

## Contributors and Collaborators
Contributions and comments are welcome on this project. 
The author is also willing to collaborate on data analytics projects.

## License
[MIT]
(https://choosealicense.com/licenses/mit/)
