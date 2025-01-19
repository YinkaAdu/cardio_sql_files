SELECT *
FROM cardio_train_incidence
ORDER BY 2;

/*choosing more descriptive column names*/
ALTER TABLE cardio_train_incidence
	CHANGE COLUMN height height_in_cm
		INT NULL;
			
ALTER TABLE cardio_train_incidence
	CHANGE COLUMN weight weight_in_kg
		INT NULL;
        
ALTER TABLE cardio_train_incidence
	ADD age_in_years
		DECIMAL(10, 2)
			AFTER age_in_days;
ALTER TABLE cardio_train_incidence
	ADD calc_body_mass_index
		FLOAT Default 0
			AFTER weight_in_kg;
ALTER TABLE cardio_train_incidence
DROP COLUMN calc_body_mass_index;

/* Calculate the age in years (add new column age_in_years)
Calculate the BMI (add new column body_mass_index)
Rank the BMI - 1 : underweight, 2 : healthy, 3 : overweight, 4 : obese, 5 : severely obese (add new column bmi_ranking)*/
	
GRANT UPDATE ON cardio_train_incidence TO root@localhost;

UPDATE cardio_train_incidence
SET
	age_in_years = age_in_days / 365.25
WHERE
	2 IS NOT NULL;
UPDATE cardio_train_incidence
SET
	body_mass_index = IFNULL(weight_in_kg /((height_in_cm/100) * (height_in_cm/100)), 0);

UPDATE cardio_train_incidence
SET
	bmi_ranking = 1 
WHERE
	body_mass_index < 18.50;
UPDATE cardio_train_incidence
SET
	bmi_ranking = 2 
WHERE
	body_mass_index > 18.50 AND body_mass_index < 25.00;
UPDATE cardio_train_incidence
SET
	bmi_ranking = 3 
WHERE
	body_mass_index > 25.00 AND body_mass_index < 30.00;
UPDATE cardio_train_incidence
SET
	bmi_ranking = 4 
WHERE
	body_mass_index > 30.00 AND body_mass_index < 40.00;
UPDATE cardio_train_incidence
SET
	bmi_ranking = 5 
WHERE
	body_mass_index > 40.00;

/* Convert 'TRUE' and 'FALSE' texts in the columns - smoker, alcohol, active, cardio_condition into boolean*/

UPDATE cardio_train_incidence
SET smoker = 
    CASE 
        WHEN UPPER(smoker) = 'TRUE' THEN 1
        WHEN UPPER(smoker) = 'FALSE' THEN 0
        ELSE NULL
	END;
UPDATE cardio_train_incidence
SET alcohol = 
    CASE 
        WHEN UPPER(alcohol) = 'TRUE' THEN 1
        WHEN UPPER(alcohol) = 'FALSE' THEN 0
        ELSE NULL
	END;
    UPDATE cardio_train_incidence
SET active = 
    CASE 
        WHEN UPPER(active) = 'TRUE' THEN 1
        WHEN UPPER(active) = 'FALSE' THEN 0
        ELSE NULL
	END;
    UPDATE cardio_train_incidence
SET cardio_condition = 
    CASE 
        WHEN UPPER(cardio_condition) = 'TRUE' THEN 1
        WHEN UPPER(cardio_condition) = 'FALSE' THEN 0
        ELSE NULL
	END;

/* Exploration
 Total Females with cardiovascular conditions vs Total Males with.....
 Total number of participants in the different bmi categories; glucose level rankings ; and cholesterol level rankings
 Total number of smokers, alcohol consumers, and (physically) active participants */

/*TEMP TABLES
Exploring the presence or absence of cardiovascular conditions across sexes*/	
CREATE TABLE cardio_condition_count (
    total_cardio_condition BIGINT, 
    total_cardio BIGINT, 
    total_non_cardio BIGINT, 
    female_cardio BIGINT, 
    female_non_cardio BIGINT, 
    male_cardio BIGINT, 
    male_non_cardio BIGINT 
    );
 
INSERT INTO cardio_condition_count (
    total_cardio_condition,
    total_cardio,
    total_non_cardio,
    female_cardio,
    female_non_cardio,
    male_cardio,
    male_non_cardio)

	SELECT 
		COUNT(*) AS total_cardio_condition,
        COUNT(CASE WHEN cardio_condition is TRUE THEN 1 ELSE NULL END) AS total_cardio,
        COUNT(CASE WHEN cardio_condition is FALSE THEN 1 ELSE NULL END) AS total_non_cardio,
        COUNT(CASE WHEN sex = 'female' AND cardio_condition is TRUE THEN 1 ELSE NULL END) AS female_cardio,
        COUNT(CASE WHEN sex = 'female' AND cardio_condition is FALSE THEN 1 ELSE NULL END) AS female_non_cardio,
        COUNT(CASE WHEN sex = 'male' AND cardio_condition is TRUE THEN 1 ELSE NULL END) AS male_cardio,
        COUNT(CASE WHEN sex = 'male' AND cardio_condition is FALSE THEN 1 ELSE NULL END) AS male_non_cardio
FROM cardio_train_incidence;
	
SELECT*
FROM cardio_condition_count;

/*Computing the percentage of participant population in selected groups (sexs, cardio_condition*/
CREATE TABLE cardio_condition_percent (
    totalCpercent DECIMAL(10,2),
    femaleNCpercent DECIMAL(10,2),
    femaleCpercent DECIMAL(10,2), 
    maleNCpercent DECIMAL(10,2),
    maleCpercent DECIMAL(10,2),
    femaleNCperTotal DECIMAL(10,2), 
    femaleCperTotal DECIMAL(10,2), 
    maleNCperTotal DECIMAL(10,2),
    maleCperTotal DECIMAL(10,2)
    );
    
INSERT INTO cardio_condition_percent(
	totalCpercent,
    femaleNCpercent,
    femaleCpercent, 
    maleNCpercent,
    maleCpercent,
    femaleNCperTotal, 
    femaleCperTotal, 
    maleNCperTotal,
    maleCperTotal
    )

	SELECT ((total_cardio/total_cardio_condition)*100) AS totalCpercent,
		((female_non_cardio/total_non_cardio)*100) AS femaleNCpercent,
		((female_cardio/total_cardio)*100) AS femaleCpercent,
        ((male_non_cardio/total_non_cardio)*100) AS maleNCpercent, 
        ((male_cardio/total_cardio)*100) AS maleCpercent,
        ((female_non_cardio/total_cardio_condition)*100) AS femaleNCperTotal,
		((female_cardio/total_cardio_condition)*100) AS femaleCperTotal,
        ((male_non_cardio/total_cardio_condition)*100) AS maleNCperTotal, 
        ((male_cardio/total_cardio_condition)*100) AS maleCperTotal
FROM cardio_condition_count;

SELECT *
FROM cardio_condition_percent;

/*Exploring ranked data (BMI, Glucose, Cholesterol)*/	
CREATE TABLE ranking_count (
    ranked_participants BIGINT,
    bmi_1_total BIGINT, 
    bmi_2_total BIGINT, 
    bmi_3_total BIGINT, 
    bmi_4_total BIGINT, 
    bmi_5_total BIGINT, 
    gluc_1_total BIGINT,
    gluc_2_total BIGINT,
    gluc_3_total BIGINT,
    chol_1_total BIGINT,
    chol_2_total BIGINT,
    chol_3_total BIGINT
   );
 
INSERT INTO ranking_count (
    ranked_participants,
    bmi_1_total, 
    bmi_2_total, 
    bmi_3_total, 
    bmi_4_total, 
    bmi_5_total, 
    gluc_1_total,
    gluc_2_total,
    gluc_3_total,
    chol_1_total,
    chol_2_total,
    chol_3_total
    )

	SELECT 
        COUNT(*) AS ranked_participants,
        COUNT(CASE WHEN bmi_ranking = 1 THEN 1 ELSE NULL END) AS bmi_1_total,
        COUNT(CASE WHEN bmi_ranking = 2 THEN 1 ELSE NULL END) AS bmi_2_total,
        COUNT(CASE WHEN bmi_ranking = 3 THEN 1 ELSE NULL END) AS bmi_3_total,
        COUNT(CASE WHEN bmi_ranking = 4 THEN 1 ELSE NULL END) AS bmi_4_total,
        COUNT(CASE WHEN bmi_ranking = 5 THEN 1 ELSE NULL END) AS bmi_5_total,
        COUNT(CASE WHEN glucose_ranking = 1 THEN 1 ELSE NULL END) AS gluc_1_total,
        COUNT(CASE WHEN glucose_ranking = 2 THEN 1 ELSE NULL END) AS gluc_2_total,
        COUNT(CASE WHEN glucose_ranking = 3 THEN 1 ELSE NULL END) AS gluc_3_total,
        COUNT(CASE WHEN cholesterol_ranking = 1 THEN 1 ELSE NULL END) AS chol_1_total,
		COUNT(CASE WHEN cholesterol_ranking = 2 THEN 1 ELSE NULL END) AS chol_2_total,
        COUNT(CASE WHEN cholesterol_ranking = 3 THEN 1 ELSE NULL END) AS chol_3_total
FROM cardio_train_incidence;
	
SELECT*
FROM ranking_count;

/*Computing the percentage of participant population in selected ranks (BMI_ranking, glucose_ranking, cholesterol_ranking).*/
CREATE TABLE ranking_percent (
    bmi_1_percent DECIMAL(10,2),
    bmi_2_percent DECIMAL(10,2),
    bmi_3_percent DECIMAL(10,2), 
    bmi_4_percent DECIMAL(10,2),
    bmi_5_percent DECIMAL(10,2),
    gluc_1_percent DECIMAL(10,2),
    gluc_2_percent DECIMAL(10,2), 
    gluc_3_percent DECIMAL(10,2), 
    chol_1_percent DECIMAL(10,2),
    chol_2_percent DECIMAL(10,2),
    chol_3_percent DECIMAL(10,2)
    );
    
INSERT INTO ranking_percent(
	bmi_1_percent,
    bmi_2_percent,
    bmi_3_percent, 
    bmi_4_percent,
    bmi_5_percent,
    gluc_1_percent,
    gluc_2_percent, 
    gluc_3_percent, 
    chol_1_percent,
    chol_2_percent,
    chol_3_percent
    )

	SELECT ((bmi_1_total/ranked_participants)*100) AS bmi_1_percent,
		((bmi_2_total/ranked_participants)*100) AS bmi_2_percent,
		((bmi_3_total/ranked_participants)*100) AS bmi_3_percent,
		((bmi_4_total/ranked_participants)*100) AS bmi_4_percent,
		((bmi_5_total/ranked_participants)*100) AS bmi_5_percent,
        ((gluc_1_total/ranked_participants)*100) AS gluc_1_percent,
        ((gluc_2_total/ranked_participants)*100) AS gluc_2_percent,
		((gluc_3_total/ranked_participants)*100) AS gluc_3_percent,
        ((chol_1_total/ranked_participants)*100) AS chol_1_percent, 
        ((chol_2_total/ranked_participants)*100) AS chol_2_percent,
        ((chol_3_total/ranked_participants)*100) AS chol_3_percent
FROM ranking_count;

SELECT *
FROM ranking_percent;

/*Exploring boolean data (smoker, alcohol, active)*/	
CREATE TABLE lifestyle_count (
    lifestyle_total BIGINT,
    smoker_count BIGINT, 
    non_smoker_count BIGINT, 
    alcohol_drinker_count BIGINT, 
    non_drinker_count BIGINT, 
    active_count BIGINT, 
    inactive_count BIGINT
   );
 
INSERT INTO lifestyle_count (
    lifestyle_total,
    smoker_count, 
    non_smoker_count, 
    alcohol_drinker_count, 
    non_drinker_count, 
    active_count, 
    inactive_count
    )

	SELECT 
        COUNT(*) AS lifestyle_total,
        COUNT(CASE WHEN smoker is TRUE THEN 1 ELSE NULL END) AS smoker_count,
        COUNT(CASE WHEN smoker is FALSE THEN 1 ELSE NULL END) AS non_smoker_count,
        COUNT(CASE WHEN alcohol is TRUE THEN 1 ELSE NULL END) AS alcohol_drinker_count,
        COUNT(CASE WHEN alcohol is FALSE THEN 1 ELSE NULL END) AS non_drinker_count,
        COUNT(CASE WHEN active is TRUE THEN 1 ELSE NULL END) AS active_count,
        COUNT(CASE WHEN active is FALSE THEN 1 ELSE NULL END) AS inactive_count
FROM cardio_train_incidence;

SELECT*
FROM lifestyle_count;

/*Computing the percentage of participant population in selected groups (smoker, alcohol, active).*/
CREATE TABLE lifestyle_percent (
    smoker_percent DECIMAL(10,2),
    non_smoker_percent DECIMAL(10,2),
    alcohol_drinker_percent DECIMAL(10,2), 
    non_drinker_percent DECIMAL(10,2),
    active_percent DECIMAL(10,2),
    inactive_percent DECIMAL(10,2)
    );
    
INSERT INTO lifestyle_percent(
	smoker_percent,
    non_smoker_percent,
    alcohol_drinker_percent, 
    non_drinker_percent,
    active_percent,
    inactive_percent
    )

	SELECT ((smoker_count/lifestyle_total)*100) AS smoker_percent,
		((non_smoker_count/lifestyle_total)*100) AS bmi_2_percent,
		((alcohol_drinker_count/lifestyle_total)*100) AS alcohol_drinker_percent,
		((non_drinker_count/lifestyle_total)*100) AS non_drinker_percent,
		((active_count/lifestyle_total)*100) AS active_percent,
        ((inactive_count/lifestyle_total)*100) AS inactive_percent
FROM lifestyle_count;

SELECT *
FROM lifestyle_percent;   

/* creating views to be used to visualise data distribution
visualise ranked data distribution (BMI, glucose and cholesterol levels), 
considering age, sexes and the presence/absence of cardiovascular.
visualise the boolean data distribution (smoker/non_smoker, drinker/non_drinker, active/inactive), 
considering age, sexes and the presence/absence of cardiovascular.*/

/* compare different parameters to show the impact of each on the presence/absence of cardio_condition */
CREATE VIEW UnderweightFemaleWithoutCVD AS
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
	sex = 'female' AND bmi_ranking = 1 AND cardio_condition is FALSE;
    
   CREATE VIEW UnderweightMaleWithoutCVD AS
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
	sex = 'male' AND bmi_ranking = 1 AND cardio_condition is FALSE;
    
    /*visualise the impact of alcohol, smoking and physical activity on the compared results.*/
    CREATE VIEW OverweightMaleWithCVD AS
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
	sex = 'male' AND bmi_ranking = 3 AND cardio_condition is TRUE;
    
     CREATE VIEW OverweightFemaleWithCVD AS
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
	sex = 'female' AND bmi_ranking = 3 AND cardio_condition is TRUE;
    
     CREATE VIEW HealthyweightMaleWithCVD AS
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
	sex = 'male' AND bmi_ranking = 2 AND cardio_condition is TRUE;
    
     CREATE VIEW HealthyweightFemaleWithCVD AS
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
	sex = 'female' AND bmi_ranking = 2 AND cardio_condition is TRUE;
    
    
    CREATE VIEW ObeseFemaleWithCVD AS
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
	sex = 'female' AND bmi_ranking = 4 AND cardio_condition is TRUE;
