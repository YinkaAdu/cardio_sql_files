# Having noticed abnormally high body_mass_index, I noticed wrong entries in height_in_cm
UPDATE cardio_train_incidence
SET
	height_in_cm = height_in_cm + 100
WHERE height_in_cm < 100;

# Compute body_mass_index again
UPDATE cardio_train_incidence
SET
	body_mass_index = IFNULL(weight_in_kg /((height_in_cm/100) * (height_in_cm/100)), 0);


/* Calculate the age in years (add new column age_in_years)
Calculate the BMI (add new column body_mass_index)
Categorise different permutations of Lifestyle Habits (smoking, alcohol, active) in new column (lifestyle_habits)
1 : where smoker is False and alcohol is False and Active is False
2 : where smoker is False and alcohol is False and Active is True
3 : where smoker is False and alcohol is True and Active is False
4 : where smoker is False and alcohol is True and Active is True
5 : where smoker is True and alcohol is False and Active is False
6 : where smoker is True and alcohol is False and Active is True
7 : where smoker is True and alcohol is True and Active is False
8 : where smoker is True and alcohol is True and Active is True

Categorise different permutations of glucose and cholesterol ranking (normal, above normal and well above normal)
in new column (gluc_and_chol)
1 : where cholesterol_ranking = 1 and glucose_ranking = 1
2 : where cholesterol_ranking = 1 and glucose_ranking = 2
3 : where cholesterol_ranking = 1 and glucose_ranking = 3
4 : where cholesterol_ranking = 2 and glucose_ranking = 1
5 : where cholesterol_ranking = 2 and glucose_ranking = 2
6 : where cholesterol_ranking = 2 and glucose_ranking = 3
7 : where cholesterol_ranking = 3 and glucose_ranking = 1
8 : where cholesterol_ranking = 3 and glucose_ranking = 2
9 : where cholesterol_ranking = 3 and glucose_ranking = 3

Export table to use for multivariate analysis in jupyter notebook */


GRANT UPDATE ON cardio_train_incidence TO root@localhost;

UPDATE cardio_train_incidence
SET
	lifestyle_habits = 1
WHERE 
	(smoker is False AND alcohol is False AND active is False);

UPDATE cardio_train_incidence
SET 
	lifestyle_habits = 2
WHERE 
	(smoker is False AND alcohol is False AND active is True);

UPDATE cardio_train_incidence
SET 
	lifestyle_habits = 3
WHERE 
	(smoker is False AND alcohol is True AND active is False);
    
UPDATE cardio_train_incidence
SET 
	lifestyle_habits = 4
WHERE 
	(smoker is False AND alcohol is True AND active is True);
    
UPDATE cardio_train_incidence
SET 
	lifestyle_habits = 5
WHERE 
	(smoker is True AND alcohol is False AND active is False);
    
UPDATE cardio_train_incidence
SET 
	lifestyle_habits = 6
WHERE 
	(smoker is True AND alcohol is False AND active is True);
    
UPDATE cardio_train_incidence
SET 
	lifestyle_habits = 7
WHERE 
	(smoker is True AND alcohol is True AND active is False);

UPDATE cardio_train_incidence
SET 
	lifestyle_habits = 8
WHERE 
	(smoker is True AND alcohol is True AND active is True);
    
# gluc_and_chol column
UPDATE cardio_train_incidence
SET 
	gluc_and_chol = 1
WHERE 
	(cholesterol_ranking = 1 AND glucose_ranking = 1);
    
UPDATE cardio_train_incidence
SET 
	gluc_and_chol = 2
WHERE 
	(cholesterol_ranking = 1 AND glucose_ranking = 2);
    
UPDATE cardio_train_incidence
SET 
	gluc_and_chol = 3
WHERE 
	(cholesterol_ranking = 1 AND glucose_ranking = 3);
    
UPDATE cardio_train_incidence
SET 
	gluc_and_chol = 4
WHERE 
	(cholesterol_ranking = 2 AND glucose_ranking = 1);
    
UPDATE cardio_train_incidence
SET 
	gluc_and_chol = 5
WHERE 
	(cholesterol_ranking = 2 AND glucose_ranking = 2);
    
UPDATE cardio_train_incidence
SET 
	gluc_and_chol = 6
WHERE 
	(cholesterol_ranking = 2 AND glucose_ranking = 3);
    
UPDATE cardio_train_incidence
SET 
	gluc_and_chol = 7
WHERE 
	(cholesterol_ranking = 3 AND glucose_ranking = 1);

UPDATE cardio_train_incidence
SET 
	gluc_and_chol = 8
WHERE 
	(cholesterol_ranking = 3 AND glucose_ranking = 2);
    
UPDATE cardio_train_incidence
SET 
	gluc_and_chol = 9
WHERE 
	(cholesterol_ranking = 3 AND glucose_ranking = 3);
    
SELECT *
FROM cardio_train_incidence;

DELETE FROM cardio_train_incidence
WHERE body_mass_index > 60.00;


SELECT 
    age_in_years,
    glucose_ranking,
    cholesterol_ranking,
    smoker,
    alcohol,
    active
FROM
    cardio_train_incidence
WHERE
    bmi_ranking = 3 AND sex = 'female' AND cardio_condition is True;

SELECT 
    age_in_years,
    glucose_ranking,
    cholesterol_ranking,
    smoker,
    alcohol,
    active
FROM
    cardio_train_incidence
WHERE
    bmi_ranking = 3 AND sex = 'male' AND cardio_condition is True;

SELECT
	age_in_years,
    glucose_ranking,
    cholesterol_ranking,
    smoker,
    alcohol,
    active
FROM cardio_train_incidence
WHERE bmi_ranking = 2 AND sex = 'female' AND cardio_condition is True;

SELECT
	age_in_years,
    glucose_ranking,
    cholesterol_ranking,
    smoker,
    alcohol,
    active
FROM cardio_train_incidence
WHERE bmi_ranking = 2 AND sex = 'male' AND cardio_condition is True;

SELECT
	age_in_years,
    glucose_ranking,
    cholesterol_ranking,
    smoker,
    alcohol,
    active
FROM cardio_train_incidence
WHERE bmi_ranking = 1 AND sex = 'female' AND cardio_condition is False;

