-- ============================================================
-- PGDA0526 - PHASE 2 LEVEL 2 SQL PRACTICAL EXAMINATION
-- PROJECT: DIABETES RISK PREDICTION ANALYSIS
-- SQL ENVIRONMENT: MYSQL
-- DATABASE: pgda0526_diabetes_exam
-- MAIN TABLE: diabetes_risk_prediction
--
-- STRUCTURE:
-- 5 analytical perspectives
-- 15 questions per perspective
-- 5 Easy + 5 Medium + 5 Difficult
-- Total analytical questions: 75
--
-- PREREQUISITE:
-- The approved diabetes dataset must already be imported into
-- the diabetes_risk_prediction table before this script is run.
-- ============================================================

CREATE DATABASE IF NOT EXISTS pgda0526_diabetes_exam;
USE pgda0526_diabetes_exam;

-- =========================================================
-- DATABASE SETUP AND FINAL VALIDATION
-- =========================================================

-- Verify final imported dataset
SELECT COUNT(*) AS total_rows
FROM diabetes_risk_prediction;

-- Preview the dataset (deliberate table profiling – SELECT * permitted)
SELECT *
FROM diabetes_risk_prediction
LIMIT 10;

-- ============================================================
-- PERSPECTIVE 1: DEMOGRAPHIC AND POPULATION RISK PROFILE
-- ============================================================

-- ========================= EASY ==============================

-- ============================================================
-- Q1 | PERSPECTIVE 1 | EASY
-- Question: Which patients are classified as having High diabetes risk?
-- Concept: Basic WHERE filtering
-- ============================================================
SELECT
    Patient_ID,
    Age,
    Gender,
    Country,
    Diabetes_Risk,
    Diabetes_Risk_Score
FROM diabetes_risk_prediction
WHERE Diabetes_Risk = 'High';

-- ============================================================
-- Q2 | PERSPECTIVE 1 | EASY
-- Question: Which patients are aged 60 years or above?
-- Concept: WHERE filtering with comparison operator
-- ============================================================
SELECT
    Patient_ID,
    Age,
    Gender,
    Country,
    Diabetes_Risk,
    Diabetes_Risk_Score
FROM diabetes_risk_prediction
WHERE Age >= 60;

-- ============================================================
-- Q3 | PERSPECTIVE 1 | EASY
-- Question: Which patients aged 60 years or above are classified
-- as having High diabetes risk?
-- Concept: WHERE filtering with multiple conditions
-- ============================================================
SELECT
    Patient_ID,
    Age,
    Gender,
    Country,
    Diabetes_Risk,
    Diabetes_Risk_Score
FROM diabetes_risk_prediction
WHERE Age >= 60
  AND Diabetes_Risk = 'High';

-- ============================================================
-- Q4 | PERSPECTIVE 1 | EASY
-- Question: What distinct gender categories are represented in the dataset?
-- Concept: SELECT DISTINCT with ORDER BY
-- ============================================================
SELECT DISTINCT Gender
FROM diabetes_risk_prediction
ORDER BY Gender;

-- ============================================================
-- Q5 | PERSPECTIVE 1 | EASY
-- Question: What distinct countries are represented in the dataset?
-- Concept: SELECT DISTINCT with ORDER BY
-- ============================================================
SELECT DISTINCT Country
FROM diabetes_risk_prediction
ORDER BY Country;

-- ======================== MEDIUM =============================

-- ============================================================
-- Q6 | PERSPECTIVE 1 | MEDIUM
-- Question: How many patients belong to each diabetes-risk category?
-- Concept: GROUP BY with COUNT
-- ============================================================
SELECT
    Diabetes_Risk,
    COUNT(*) AS patient_count
FROM diabetes_risk_prediction
GROUP BY Diabetes_Risk
ORDER BY patient_count DESC;

-- ============================================================
-- Q7 | PERSPECTIVE 1 | MEDIUM
-- Question: What is the average diabetes-risk score for each gender?
-- Concept: GROUP BY with AVG and ROUND
-- ============================================================
SELECT
    Gender,
    ROUND(AVG(Diabetes_Risk_Score), 2) AS average_risk_score
FROM diabetes_risk_prediction
GROUP BY Gender
ORDER BY average_risk_score DESC;

-- ============================================================
-- Q8 | PERSPECTIVE 1 | MEDIUM
-- Question: How many High-risk patients are there within each gender?
-- Concept: WHERE with GROUP BY and COUNT
-- ============================================================
SELECT
    Gender,
    COUNT(*) AS high_risk_patient_count
FROM diabetes_risk_prediction
WHERE Diabetes_Risk = 'High'
GROUP BY Gender
ORDER BY high_risk_patient_count DESC;

-- ============================================================
-- Q9 | PERSPECTIVE 1 | MEDIUM
-- Question: What is the average age of patients within each
-- diabetes-risk category?
-- Concept: GROUP BY with AVG
-- ============================================================
SELECT
    Diabetes_Risk,
    ROUND(AVG(Age), 2) AS average_age
FROM diabetes_risk_prediction
GROUP BY Diabetes_Risk
ORDER BY average_age DESC;

-- ============================================================
-- Q10 | PERSPECTIVE 1 | MEDIUM
-- Question: Which countries have the highest numbers of High-risk patients?
-- Concept: WHERE with GROUP BY, COUNT and ORDER BY
-- ============================================================
SELECT
    Country,
    COUNT(*) AS high_risk_patient_count
FROM diabetes_risk_prediction
WHERE Diabetes_Risk = 'High'
GROUP BY Country
ORDER BY high_risk_patient_count DESC;

-- ======================= DIFFICULT ===========================

-- ============================================================
-- Q11 | PERSPECTIVE 1 | DIFFICULT
-- Question: What percentage of patients within each gender
-- are classified as High diabetes risk?
-- Concept: Conditional aggregation and percentage calculation
-- ============================================================
SELECT
    Gender,
    COUNT(*) AS total_patients,
    SUM(Diabetes_Risk = 'High') AS high_risk_patients,
    ROUND(
        100.0 * SUM(Diabetes_Risk = 'High') / COUNT(*),
        2
    ) AS high_risk_percentage
FROM diabetes_risk_prediction
GROUP BY Gender
ORDER BY high_risk_percentage DESC;

-- ============================================================
-- Q12 | PERSPECTIVE 1 | DIFFICULT
-- Question: How can countries be ranked according to their
-- average diabetes-risk score?
-- Concept: Aggregation with DENSE_RANK window function
-- ============================================================
SELECT
    Country,
    ROUND(AVG(Diabetes_Risk_Score), 2) AS average_risk_score,
    DENSE_RANK() OVER (
        ORDER BY AVG(Diabetes_Risk_Score) DESC
    ) AS country_rank
FROM diabetes_risk_prediction
GROUP BY Country
ORDER BY country_rank, Country;

-- ============================================================
-- Q13 | PERSPECTIVE 1 | DIFFICULT
-- Question: How do patients rank by diabetes-risk score
-- within their respective countries?
-- Concept: DENSE_RANK with PARTITION BY
-- ============================================================
SELECT
    Patient_ID,
    Country,
    Diabetes_Risk_Score,
    DENSE_RANK() OVER (
        PARTITION BY Country
        ORDER BY Diabetes_Risk_Score DESC
    ) AS patient_rank
FROM diabetes_risk_prediction
ORDER BY Country, patient_rank, Patient_ID;

-- ============================================================
-- Q14 | PERSPECTIVE 1 | DIFFICULT
-- Question: Which age groups have a proportion of High-risk patients
-- greater than the overall proportion of High-risk patients?
-- Concept: Multiple CTEs, CASE and conditional aggregation
-- ============================================================
WITH age_groups AS (
    SELECT
        CASE
            WHEN Age < 30 THEN 'Under 30'
            WHEN Age BETWEEN 30 AND 44 THEN '30-44'
            WHEN Age BETWEEN 45 AND 59 THEN '45-59'
            WHEN Age BETWEEN 60 AND 74 THEN '60-74'
            WHEN Age >= 75 THEN '75+'
        END AS age_group,
        Diabetes_Risk
    FROM diabetes_risk_prediction
    WHERE Age IS NOT NULL
),
group_rates AS (
    SELECT
        age_group,
        COUNT(*) AS total_patients,
        SUM(Diabetes_Risk = 'High') AS high_risk_patients,
        100.0 * SUM(Diabetes_Risk = 'High') / COUNT(*) AS high_risk_percentage
    FROM age_groups
    GROUP BY age_group
),
overall_rate AS (
    SELECT
        100.0 * SUM(Diabetes_Risk = 'High') / COUNT(*) AS overall_high_risk_percentage
    FROM diabetes_risk_prediction
)
SELECT
    g.age_group,
    g.total_patients,
    g.high_risk_patients,
    ROUND(g.high_risk_percentage, 2) AS high_risk_percentage,
    ROUND(o.overall_high_risk_percentage, 2) AS overall_high_risk_percentage
FROM group_rates g
CROSS JOIN overall_rate o
WHERE g.high_risk_percentage > o.overall_high_risk_percentage
ORDER BY g.high_risk_percentage DESC;

-- ============================================================
-- Q15 | PERSPECTIVE 1 | DIFFICULT
-- Question: How do countries rank by the percentage of patients
-- classified as High diabetes risk?
-- Concept: Conditional aggregation with DENSE_RANK
-- ============================================================
SELECT
    Country,
    COUNT(*) AS total_patients,
    SUM(Diabetes_Risk = 'High') AS high_risk_patients,
    ROUND(
        100.0 * SUM(Diabetes_Risk = 'High') / COUNT(*),
        2
    ) AS high_risk_percentage,
    DENSE_RANK() OVER (
        ORDER BY
            100.0 * SUM(Diabetes_Risk = 'High') / COUNT(*) DESC
    ) AS country_rank
FROM diabetes_risk_prediction
GROUP BY Country
ORDER BY country_rank, Country;

-- ============================================================
-- PERSPECTIVE 2: CLINICAL AND METABOLIC RISK INDICATORS
-- ============================================================

-- ========================= EASY ==============================

-- ============================================================
-- Q16 | PERSPECTIVE 2 | EASY
-- Question: Which patients have a blood glucose level above 180?
-- Concept: WHERE filtering
-- ============================================================
SELECT
    Patient_ID,
    Blood_Glucose,
    Diabetes_Risk,
    Diabetes_Risk_Score
FROM diabetes_risk_prediction
WHERE Blood_Glucose > 180;

-- ============================================================
-- Q17 | PERSPECTIVE 2 | EASY
-- Question: Which patients have an HbA1c level above 6.5?
-- Concept: WHERE filtering
-- ============================================================
SELECT
    Patient_ID,
    HbA1c,
    Diabetes_Risk,
    Diabetes_Risk_Score
FROM diabetes_risk_prediction
WHERE HbA1c > 6.5;

-- ============================================================
-- Q18 | PERSPECTIVE 2 | EASY
-- Question: Which patients have a BMI of 30 or above?
-- Concept: WHERE filtering with comparison operator
-- ============================================================
SELECT
    Patient_ID,
    BMI,
    Diabetes_Risk,
    Diabetes_Risk_Score
FROM diabetes_risk_prediction
WHERE BMI >= 30;

-- ============================================================
-- Q19 | PERSPECTIVE 2 | EASY
-- Question: Which patients have both a blood glucose level above 180
-- and High diabetes risk?
-- Concept: Multi-condition WHERE filtering
-- ============================================================
SELECT
    Patient_ID,
    Blood_Glucose,
    Diabetes_Risk,
    Diabetes_Risk_Score
FROM diabetes_risk_prediction
WHERE Blood_Glucose > 180
  AND Diabetes_Risk = 'High';

-- ============================================================
-- Q20 | PERSPECTIVE 2 | EASY
-- Question: Which patients have an HbA1c level above 6.5
-- and require a doctor consultation?
-- Concept: Multi-condition WHERE filtering
-- ============================================================
SELECT
    Patient_ID,
    HbA1c,
    Doctor_Consultation_Needed,
    Diabetes_Risk,
    Diabetes_Risk_Score
FROM diabetes_risk_prediction
WHERE HbA1c > 6.5
  AND Doctor_Consultation_Needed = 'Yes';

-- ======================== MEDIUM =============================

-- ============================================================
-- Q21 | PERSPECTIVE 2 | MEDIUM
-- Question: What is the average blood glucose level
-- for each diabetes-risk category?
-- Concept: GROUP BY with AVG
-- ============================================================
SELECT
    Diabetes_Risk,
    ROUND(AVG(Blood_Glucose), 2) AS average_blood_glucose
FROM diabetes_risk_prediction
GROUP BY Diabetes_Risk
ORDER BY average_blood_glucose DESC;

-- ============================================================
-- Q22 | PERSPECTIVE 2 | MEDIUM
-- Question: What is the average HbA1c level
-- for each diabetes-risk category?
-- Concept: GROUP BY with AVG
-- ============================================================
SELECT
    Diabetes_Risk,
    ROUND(AVG(HbA1c), 2) AS average_hba1c
FROM diabetes_risk_prediction
GROUP BY Diabetes_Risk
ORDER BY average_hba1c DESC;

-- ============================================================
-- Q23 | PERSPECTIVE 2 | MEDIUM
-- Question: What are the average BMI and waist circumference
-- for each diabetes-risk category?
-- Concept: GROUP BY with multiple AVG aggregations
-- ============================================================
SELECT
    Diabetes_Risk,
    ROUND(AVG(BMI), 2) AS average_bmi,
    ROUND(AVG(Waist_Circumference_cm), 2) AS average_waist_circumference
FROM diabetes_risk_prediction
GROUP BY Diabetes_Risk
ORDER BY average_bmi DESC;

-- ============================================================
-- Q24 | PERSPECTIVE 2 | MEDIUM
-- Question: What are the average systolic and diastolic
-- blood pressure values for each diabetes-risk category?
-- Concept: GROUP BY with multiple AVG aggregations
-- ============================================================
SELECT
    Diabetes_Risk,
    ROUND(AVG(Blood_Pressure_Systolic), 2) AS average_systolic_bp,
    ROUND(AVG(Blood_Pressure_Diastolic), 2) AS average_diastolic_bp
FROM diabetes_risk_prediction
GROUP BY Diabetes_Risk
ORDER BY average_systolic_bp DESC;

-- ============================================================
-- Q25 | PERSPECTIVE 2 | MEDIUM
-- Question: What are the average total cholesterol, HDL, LDL
-- and triglyceride levels for each diabetes-risk category?
-- Concept: GROUP BY with multiple AVG aggregations
-- ============================================================
SELECT
    Diabetes_Risk,
    ROUND(AVG(Total_Cholesterol), 2) AS average_total_cholesterol,
    ROUND(AVG(HDL), 2) AS average_hdl,
    ROUND(AVG(LDL), 2) AS average_ldl,
    ROUND(AVG(Triglycerides), 2) AS average_triglycerides
FROM diabetes_risk_prediction
GROUP BY Diabetes_Risk
ORDER BY Diabetes_Risk;

-- ======================= DIFFICULT ===========================

-- ============================================================
-- Q26 | PERSPECTIVE 2 | DIFFICULT
-- Question: How can patients be ranked according to their
-- blood glucose level within each diabetes-risk category?
-- Concept: DENSE_RANK with PARTITION BY
-- ============================================================
SELECT
    Patient_ID,
    Diabetes_Risk,
    Blood_Glucose,
    DENSE_RANK() OVER (
        PARTITION BY Diabetes_Risk
        ORDER BY Blood_Glucose DESC
    ) AS glucose_rank
FROM diabetes_risk_prediction
ORDER BY Diabetes_Risk, glucose_rank, Patient_ID;

-- ============================================================
-- Q27 | PERSPECTIVE 2 | DIFFICULT
-- Question: Which patients have a blood glucose level
-- greater than the overall average blood glucose level?
-- Concept: Scalar subquery with WHERE
-- ============================================================
SELECT
    Patient_ID,
    Blood_Glucose,
    Diabetes_Risk,
    Diabetes_Risk_Score
FROM diabetes_risk_prediction
WHERE Blood_Glucose > (
    SELECT AVG(Blood_Glucose)
    FROM diabetes_risk_prediction
);

-- ============================================================
-- Q28 | PERSPECTIVE 2 | DIFFICULT
-- Question: Which patients have an HbA1c level greater than
-- the average HbA1c level of their respective diabetes-risk category?
-- Concept: JOIN with aggregated derived table
-- ============================================================
SELECT
    d.Patient_ID,
    d.Diabetes_Risk,
    d.HbA1c
FROM diabetes_risk_prediction d
JOIN (
    SELECT
        Diabetes_Risk,
        AVG(HbA1c) AS average_hba1c
    FROM diabetes_risk_prediction
    WHERE HbA1c IS NOT NULL
    GROUP BY Diabetes_Risk
) a
    ON d.Diabetes_Risk = a.Diabetes_Risk
WHERE d.HbA1c > a.average_hba1c
ORDER BY d.Diabetes_Risk, d.HbA1c DESC;

-- ============================================================
-- Q29 | PERSPECTIVE 2 | DIFFICULT
-- Question: How can patients within each diabetes-risk category
-- be ranked according to their Diabetes_Risk_Score while also
-- displaying BMI, blood glucose and HbA1c values?
-- Concept: DENSE_RANK with PARTITION BY
-- ============================================================
SELECT
    Patient_ID,
    Diabetes_Risk,
    Diabetes_Risk_Score,
    BMI,
    Blood_Glucose,
    HbA1c,
    DENSE_RANK() OVER (
        PARTITION BY Diabetes_Risk
        ORDER BY Diabetes_Risk_Score DESC
    ) AS risk_score_rank
FROM diabetes_risk_prediction
ORDER BY Diabetes_Risk, risk_score_rank, Patient_ID;

-- ============================================================
-- Q30 | PERSPECTIVE 2 | DIFFICULT
-- Question: Which diabetes-risk categories have an average
-- blood glucose level greater than the overall average blood glucose level?
-- Concept: GROUP BY with HAVING and scalar subquery
-- ============================================================
SELECT
    Diabetes_Risk,
    ROUND(AVG(Blood_Glucose), 2) AS average_blood_glucose
FROM diabetes_risk_prediction
GROUP BY Diabetes_Risk
HAVING AVG(Blood_Glucose) > (
    SELECT AVG(Blood_Glucose)
    FROM diabetes_risk_prediction
)
ORDER BY average_blood_glucose DESC;

-- ============================================================
-- PERSPECTIVE 3: LIFESTYLE AND BEHAVIOURAL RISK FACTORS
-- ============================================================

-- ========================= EASY ==============================

-- ============================================================
-- Q31 | PERSPECTIVE 3 | EASY
-- Question: Which patients have a Low physical activity level?
-- Concept: WHERE filtering
-- ============================================================
SELECT
    Patient_ID,
    Physical_Activity_Level,
    Diabetes_Risk,
    Diabetes_Risk_Score
FROM diabetes_risk_prediction
WHERE Physical_Activity_Level = 'Low';

-- ============================================================
-- Q32 | PERSPECTIVE 3 | EASY
-- Question: Which patients have a Poor diet quality?
-- Concept: WHERE filtering
-- ============================================================
SELECT
    Patient_ID,
    Diet_Quality,
    Diabetes_Risk,
    Diabetes_Risk_Score
FROM diabetes_risk_prediction
WHERE Diet_Quality = 'Poor';

-- ============================================================
-- Q33 | PERSPECTIVE 3 | EASY
-- Question: Which patients are Current smokers?
-- Concept: WHERE filtering
-- ============================================================
SELECT
    Patient_ID,
    Smoking_Status,
    Diabetes_Risk,
    Diabetes_Risk_Score
FROM diabetes_risk_prediction
WHERE Smoking_Status = 'Current';

-- ============================================================
-- Q34 | PERSPECTIVE 3 | EASY
-- Question: Which patients have a High sugar intake?
-- Concept: WHERE filtering
-- ============================================================
SELECT
    Patient_ID,
    Sugar_Intake_Level,
    Diabetes_Risk,
    Diabetes_Risk_Score
FROM diabetes_risk_prediction
WHERE Sugar_Intake_Level = 'High';

-- ============================================================
-- Q35 | PERSPECTIVE 3 | EASY
-- Question: Which patients have a High stress level
-- and are classified as High diabetes risk?
-- Concept: Multi-condition WHERE filtering
-- ============================================================
SELECT
    Patient_ID,
    Stress_Level,
    Diabetes_Risk,
    Diabetes_Risk_Score
FROM diabetes_risk_prediction
WHERE Stress_Level = 'High'
  AND Diabetes_Risk = 'High';

-- ======================== MEDIUM =============================

-- ============================================================
-- Q36 | PERSPECTIVE 3 | MEDIUM
-- Question: How many patients belong to each physical activity level
-- and diabetes-risk category?
-- Concept: Multi-column GROUP BY with COUNT
-- ============================================================
SELECT
    Physical_Activity_Level,
    Diabetes_Risk,
    COUNT(*) AS patient_count
FROM diabetes_risk_prediction
GROUP BY Physical_Activity_Level, Diabetes_Risk
ORDER BY Physical_Activity_Level, Diabetes_Risk;

-- ============================================================
-- Q37 | PERSPECTIVE 3 | MEDIUM
-- Question: What is the average Diabetes_Risk_Score
-- for each diet-quality category?
-- Concept: GROUP BY with AVG
-- ============================================================
SELECT
    Diet_Quality,
    ROUND(AVG(Diabetes_Risk_Score), 2) AS average_risk_score
FROM diabetes_risk_prediction
GROUP BY Diet_Quality
ORDER BY average_risk_score DESC;

-- ============================================================
-- Q38 | PERSPECTIVE 3 | MEDIUM
-- Question: What is the average Diabetes_Risk_Score
-- for each smoking-status category?
-- Concept: GROUP BY with AVG
-- ============================================================
SELECT
    Smoking_Status,
    ROUND(AVG(Diabetes_Risk_Score), 2) AS average_risk_score
FROM diabetes_risk_prediction
GROUP BY Smoking_Status
ORDER BY average_risk_score DESC;

-- ============================================================
-- Q39 | PERSPECTIVE 3 | MEDIUM
-- Question: What are the average exercise hours per week
-- and daily walking minutes for each diabetes-risk category?
-- Concept: GROUP BY with multiple AVG aggregations
-- ============================================================
SELECT
    Diabetes_Risk,
    ROUND(AVG(Exercise_Hours_Per_Week), 2) AS average_exercise_hours,
    ROUND(AVG(Daily_Walking_Minutes), 2) AS average_walking_minutes
FROM diabetes_risk_prediction
GROUP BY Diabetes_Risk
ORDER BY Diabetes_Risk;

-- ============================================================
-- Q40 | PERSPECTIVE 3 | MEDIUM
-- Question: What is the average Diabetes_Risk_Score
-- for each stress-level category?
-- Concept: GROUP BY with AVG
-- ============================================================
SELECT
    Stress_Level,
    ROUND(AVG(Diabetes_Risk_Score), 2) AS average_risk_score
FROM diabetes_risk_prediction
GROUP BY Stress_Level
ORDER BY average_risk_score DESC;

-- ======================= DIFFICULT ===========================

-- ============================================================
-- Q41 | PERSPECTIVE 3 | DIFFICULT
-- Question: How can physical-activity groups be ranked
-- according to their average Diabetes_Risk_Score?
-- Concept: Aggregation with DENSE_RANK
-- ============================================================
SELECT
    Physical_Activity_Level,
    ROUND(AVG(Diabetes_Risk_Score), 2) AS average_risk_score,
    DENSE_RANK() OVER (
        ORDER BY AVG(Diabetes_Risk_Score) DESC
    ) AS activity_rank
FROM diabetes_risk_prediction
GROUP BY Physical_Activity_Level
ORDER BY activity_rank, Physical_Activity_Level;

-- ============================================================
-- Q42 | PERSPECTIVE 3 | DIFFICULT
-- Question: Which patients exercise fewer hours per week than
-- the overall average and have a Diabetes_Risk_Score above
-- the overall average?
-- Concept: Multiple scalar subqueries with WHERE
-- ============================================================
SELECT
    Patient_ID,
    Exercise_Hours_Per_Week,
    Diabetes_Risk_Score,
    Diabetes_Risk
FROM diabetes_risk_prediction
WHERE Exercise_Hours_Per_Week < (
    SELECT AVG(Exercise_Hours_Per_Week)
    FROM diabetes_risk_prediction
)
AND Diabetes_Risk_Score > (
    SELECT AVG(Diabetes_Risk_Score)
    FROM diabetes_risk_prediction
)
ORDER BY Diabetes_Risk_Score DESC;

-- ============================================================
-- Q43 | PERSPECTIVE 3 | DIFFICULT
-- Question: Within each diet-quality category, how can patients
-- be ranked according to their Diabetes_Risk_Score?
-- Concept: DENSE_RANK with PARTITION BY
-- ============================================================
SELECT
    Patient_ID,
    Diet_Quality,
    Diabetes_Risk_Score,
    DENSE_RANK() OVER (
        PARTITION BY Diet_Quality
        ORDER BY Diabetes_Risk_Score DESC
    ) AS diet_quality_rank
FROM diabetes_risk_prediction
ORDER BY Diet_Quality, diet_quality_rank, Patient_ID;

-- ============================================================
-- Q44 | PERSPECTIVE 3 | DIFFICULT
-- Question: Which combinations of physical activity level and diet quality
-- have an average Diabetes_Risk_Score greater than the overall average?
-- Concept: GROUP BY with HAVING and scalar subquery
-- ============================================================
SELECT
    Physical_Activity_Level,
    Diet_Quality,
    ROUND(AVG(Diabetes_Risk_Score), 2) AS average_risk_score
FROM diabetes_risk_prediction
GROUP BY Physical_Activity_Level, Diet_Quality
HAVING AVG(Diabetes_Risk_Score) > (
    SELECT AVG(Diabetes_Risk_Score)
    FROM diabetes_risk_prediction
)
ORDER BY average_risk_score DESC;

-- ============================================================
-- Q45 | PERSPECTIVE 3 | DIFFICULT
-- Question: How can smoking-status and alcohol-consumption groups
-- be ranked according to their average Diabetes_Risk_Score?
-- Concept: Aggregation with DENSE_RANK
-- ============================================================
SELECT
    Smoking_Status,
    Alcohol_Consumption,
    ROUND(AVG(Diabetes_Risk_Score), 2) AS average_risk_score,
    DENSE_RANK() OVER (
        ORDER BY AVG(Diabetes_Risk_Score) DESC
    ) AS lifestyle_group_rank
FROM diabetes_risk_prediction
GROUP BY Smoking_Status, Alcohol_Consumption
ORDER BY lifestyle_group_rank, Smoking_Status, Alcohol_Consumption;

-- ============================================================
-- PERSPECTIVE 4: MEDICAL HISTORY AND COMORBIDITY PROFILE
-- ============================================================

-- ========================= EASY ==============================

-- ============================================================
-- Q46 | PERSPECTIVE 4 | EASY
-- Question: Which patients have a family history of diabetes?
-- Concept: WHERE filtering
-- ============================================================
SELECT
    Patient_ID,
    Family_History_Diabetes,
    Diabetes_Risk,
    Diabetes_Risk_Score
FROM diabetes_risk_prediction
WHERE Family_History_Diabetes = 'Yes';

-- ============================================================
-- Q47 | PERSPECTIVE 4 | EASY
-- Question: Which patients have hypertension?
-- Concept: WHERE filtering
-- ============================================================
SELECT
    Patient_ID,
    Hypertension,
    Diabetes_Risk,
    Diabetes_Risk_Score
FROM diabetes_risk_prediction
WHERE Hypertension = 'Yes';

-- ============================================================
-- Q48 | PERSPECTIVE 4 | EASY
-- Question: Which patients have heart disease?
-- Concept: WHERE filtering
-- ============================================================
SELECT
    Patient_ID,
    Heart_Disease,
    Diabetes_Risk,
    Diabetes_Risk_Score
FROM diabetes_risk_prediction
WHERE Heart_Disease = 'Yes';

-- ============================================================
-- Q49 | PERSPECTIVE 4 | EASY
-- Question: Which patients have fatty liver disease?
-- Concept: WHERE filtering
-- ============================================================
SELECT
    Patient_ID,
    Fatty_Liver,
    Diabetes_Risk,
    Diabetes_Risk_Score
FROM diabetes_risk_prediction
WHERE Fatty_Liver = 'Yes';

-- ============================================================
-- Q50 | PERSPECTIVE 4 | EASY
-- Question: Which patients have a family history of diabetes
-- and are classified as High diabetes risk?
-- Concept: Multi-condition WHERE filtering
-- ============================================================
SELECT
    Patient_ID,
    Family_History_Diabetes,
    Diabetes_Risk,
    Diabetes_Risk_Score
FROM diabetes_risk_prediction
WHERE Family_History_Diabetes = 'Yes'
  AND Diabetes_Risk = 'High';

-- ======================== MEDIUM =============================

-- ============================================================
-- Q51 | PERSPECTIVE 4 | MEDIUM
-- Question: How many patients fall into each diabetes-risk category
-- according to family history of diabetes?
-- Concept: Multi-column GROUP BY with COUNT
-- ============================================================
SELECT
    Family_History_Diabetes,
    Diabetes_Risk,
    COUNT(*) AS patient_count
FROM diabetes_risk_prediction
GROUP BY Family_History_Diabetes, Diabetes_Risk
ORDER BY Family_History_Diabetes, Diabetes_Risk;

-- ============================================================
-- Q52 | PERSPECTIVE 4 | MEDIUM
-- Question: What is the average Diabetes_Risk_Score
-- for patients with and without hypertension?
-- Concept: GROUP BY with AVG
-- ============================================================
SELECT
    Hypertension,
    ROUND(AVG(Diabetes_Risk_Score), 2) AS average_risk_score
FROM diabetes_risk_prediction
GROUP BY Hypertension
ORDER BY average_risk_score DESC;

-- ============================================================
-- Q53 | PERSPECTIVE 4 | MEDIUM
-- Question: What is the average Diabetes_Risk_Score
-- for patients with and without heart disease?
-- Concept: GROUP BY with AVG
-- ============================================================
SELECT
    Heart_Disease,
    ROUND(AVG(Diabetes_Risk_Score), 2) AS average_risk_score
FROM diabetes_risk_prediction
GROUP BY Heart_Disease
ORDER BY average_risk_score DESC;

-- ============================================================
-- Q54 | PERSPECTIVE 4 | MEDIUM
-- Question: How many High-risk patients have fatty liver disease?
-- Concept: COUNT with multi-condition WHERE
-- ============================================================
SELECT
    COUNT(*) AS high_risk_fatty_liver_patients
FROM diabetes_risk_prediction
WHERE Diabetes_Risk = 'High'
  AND Fatty_Liver = 'Yes';

-- ============================================================
-- Q55 | PERSPECTIVE 4 | MEDIUM
-- Question: What is the average Diabetes_Risk_Score
-- for patients with and without PCOS?
-- Concept: GROUP BY with AVG
-- ============================================================
SELECT
    PCOS,
    ROUND(AVG(Diabetes_Risk_Score), 2) AS average_risk_score
FROM diabetes_risk_prediction
GROUP BY PCOS
ORDER BY average_risk_score DESC;

-- ======================= DIFFICULT ===========================

-- ============================================================
-- Q56 | PERSPECTIVE 4 | DIFFICULT
-- Question: How can patients with a family history of diabetes
-- be ranked according to their Diabetes_Risk_Score?
-- Concept: DENSE_RANK window function
-- ============================================================
SELECT
    Patient_ID,
    Family_History_Diabetes,
    Diabetes_Risk_Score,
    DENSE_RANK() OVER (
        ORDER BY Diabetes_Risk_Score DESC
    ) AS risk_score_rank
FROM diabetes_risk_prediction
WHERE Family_History_Diabetes = 'Yes'
ORDER BY risk_score_rank, Patient_ID;

-- ============================================================
-- Q57 | PERSPECTIVE 4 | DIFFICULT
-- Question: Which patients with hypertension have a Diabetes_Risk_Score
-- greater than the average score of patients with hypertension?
-- Concept: Scalar subquery with WHERE
-- ============================================================
SELECT
    Patient_ID,
    Hypertension,
    Diabetes_Risk_Score,
    Diabetes_Risk
FROM diabetes_risk_prediction
WHERE Hypertension = 'Yes'
  AND Diabetes_Risk_Score > (
      SELECT AVG(Diabetes_Risk_Score)
      FROM diabetes_risk_prediction
      WHERE Hypertension = 'Yes'
  )
ORDER BY Diabetes_Risk_Score DESC, Patient_ID;

-- ============================================================
-- Q58 | PERSPECTIVE 4 | DIFFICULT
-- Question: Which combinations of hypertension and heart disease
-- have an average Diabetes_Risk_Score greater than the overall average?
-- Concept: GROUP BY with HAVING and scalar subquery
-- ============================================================
SELECT
    Hypertension,
    Heart_Disease,
    ROUND(AVG(Diabetes_Risk_Score), 2) AS average_risk_score
FROM diabetes_risk_prediction
GROUP BY Hypertension, Heart_Disease
HAVING AVG(Diabetes_Risk_Score) > (
    SELECT AVG(Diabetes_Risk_Score)
    FROM diabetes_risk_prediction
)
ORDER BY average_risk_score DESC;

-- ============================================================
-- Q59 | PERSPECTIVE 4 | DIFFICULT
-- Question: How can comorbidity groups be ranked
-- according to their average Diabetes_Risk_Score?
-- Concept: Multi-column aggregation with DENSE_RANK
-- ============================================================
SELECT
    Hypertension,
    Heart_Disease,
    Fatty_Liver,
    PCOS,
    ROUND(AVG(Diabetes_Risk_Score), 2) AS average_risk_score,
    DENSE_RANK() OVER (
        ORDER BY AVG(Diabetes_Risk_Score) DESC
    ) AS comorbidity_rank
FROM diabetes_risk_prediction
GROUP BY
    Hypertension,
    Heart_Disease,
    Fatty_Liver,
    PCOS
ORDER BY comorbidity_rank,
         Hypertension,
         Heart_Disease,
         Fatty_Liver,
         PCOS;

-- ============================================================
-- Q60 | PERSPECTIVE 4 | DIFFICULT
-- Question: Which patients have two or more recorded conditions among
-- hypertension, heart disease, fatty liver and PCOS, and how do
-- their Diabetes_Risk_Scores compare with the overall average?
-- Concept: CASE, conditional logic and scalar subquery
-- ============================================================
SELECT
    Patient_ID,
    Hypertension,
    Heart_Disease,
    Fatty_Liver,
    PCOS,
    (
        COALESCE(Hypertension = 'Yes', 0) +
        COALESCE(Heart_Disease = 'Yes', 0) +
        COALESCE(Fatty_Liver = 'Yes', 0) +
        COALESCE(PCOS = 'Yes', 0)
    ) AS condition_count,
    Diabetes_Risk_Score,
    ROUND(
        (SELECT AVG(Diabetes_Risk_Score)
         FROM diabetes_risk_prediction),
        2
    ) AS overall_average_risk_score,
    CASE
        WHEN Diabetes_Risk_Score >
             (SELECT AVG(Diabetes_Risk_Score)
              FROM diabetes_risk_prediction)
        THEN 'Above Average'
        WHEN Diabetes_Risk_Score <
             (SELECT AVG(Diabetes_Risk_Score)
              FROM diabetes_risk_prediction)
        THEN 'Below Average'
        ELSE 'Equal to Average'
    END AS risk_score_comparison
FROM diabetes_risk_prediction
WHERE
    (
        COALESCE(Hypertension = 'Yes', 0) +
        COALESCE(Heart_Disease = 'Yes', 0) +
        COALESCE(Fatty_Liver = 'Yes', 0) +
        COALESCE(PCOS = 'Yes', 0)
    ) >= 2
ORDER BY
    condition_count DESC,
    Diabetes_Risk_Score DESC,
    Patient_ID;

-- ============================================================
-- PERSPECTIVE 5: PREVENTION, RISK STRATIFICATION
-- AND HEALTHCARE RESPONSE
-- ============================================================

-- ========================= EASY ==============================

-- ============================================================
-- Q61 | PERSPECTIVE 5 | EASY
-- Question: Which patients require a doctor consultation?
-- Concept: WHERE filtering
-- ============================================================
SELECT
    Patient_ID,
    Doctor_Consultation_Needed,
    Diabetes_Risk,
    Diabetes_Risk_Score
FROM diabetes_risk_prediction
WHERE Doctor_Consultation_Needed = 'Yes';

-- ============================================================
-- Q62 | PERSPECTIVE 5 | EASY
-- Question: Which patients have a Diabetes_Risk_Score of 80 or above?
-- Concept: WHERE filtering with comparison operator
-- ============================================================
SELECT
    Patient_ID,
    Diabetes_Risk_Score,
    Diabetes_Risk
FROM diabetes_risk_prediction
WHERE Diabetes_Risk_Score >= 80;

-- ============================================================
-- Q63 | PERSPECTIVE 5 | EASY
-- Question: Which patients are classified as High diabetes risk
-- and require a doctor consultation?
-- Concept: Multi-condition WHERE filtering
-- ============================================================
SELECT
    Patient_ID,
    Diabetes_Risk,
    Doctor_Consultation_Needed,
    Diabetes_Risk_Score
FROM diabetes_risk_prediction
WHERE Diabetes_Risk = 'High'
  AND Doctor_Consultation_Needed = 'Yes';

-- ============================================================
-- Q64 | PERSPECTIVE 5 | EASY
-- Question: What distinct AI health recommendations are present
-- in the dataset?
-- Concept: SELECT DISTINCT with ORDER BY
-- ============================================================
SELECT DISTINCT AI_Health_Recommendation
FROM diabetes_risk_prediction
ORDER BY AI_Health_Recommendation;

-- ============================================================
-- Q65 | PERSPECTIVE 5 | EASY
-- Question: Which patients have Poor medication adherence?
-- Concept: WHERE filtering
-- ============================================================
SELECT
    Patient_ID,
    Medication_Adherence,
    Diabetes_Risk,
    Diabetes_Risk_Score
FROM diabetes_risk_prediction
WHERE Medication_Adherence = 'Poor';

-- ======================== MEDIUM =============================

-- ============================================================
-- Q66 | PERSPECTIVE 5 | MEDIUM
-- Question: How many patients require a doctor consultation
-- within each diabetes-risk category?
-- Concept: WHERE with GROUP BY and COUNT
-- ============================================================
SELECT
    Diabetes_Risk,
    COUNT(*) AS consultation_required_count
FROM diabetes_risk_prediction
WHERE Doctor_Consultation_Needed = 'Yes'
GROUP BY Diabetes_Risk
ORDER BY consultation_required_count DESC;

-- ============================================================
-- Q67 | PERSPECTIVE 5 | MEDIUM
-- Question: What is the average Diabetes_Risk_Score for patients
-- who require and do not require a doctor consultation?
-- Concept: GROUP BY with AVG
-- ============================================================
SELECT
    Doctor_Consultation_Needed,
    ROUND(AVG(Diabetes_Risk_Score), 2) AS average_risk_score
FROM diabetes_risk_prediction
GROUP BY Doctor_Consultation_Needed
ORDER BY average_risk_score DESC;

-- ============================================================
-- Q68 | PERSPECTIVE 5 | MEDIUM
-- Question: How many patients receive each AI health recommendation?
-- Concept: GROUP BY with COUNT
-- ============================================================
SELECT
    AI_Health_Recommendation,
    COUNT(*) AS patient_count
FROM diabetes_risk_prediction
GROUP BY AI_Health_Recommendation
ORDER BY patient_count DESC, AI_Health_Recommendation;

-- ============================================================
-- Q69 | PERSPECTIVE 5 | MEDIUM
-- Question: What is the average Diabetes_Risk_Score
-- for each AI health recommendation?
-- Concept: GROUP BY with AVG
-- ============================================================
SELECT
    AI_Health_Recommendation,
    ROUND(AVG(Diabetes_Risk_Score), 2) AS average_risk_score
FROM diabetes_risk_prediction
GROUP BY AI_Health_Recommendation
ORDER BY average_risk_score DESC;

-- ============================================================
-- Q70 | PERSPECTIVE 5 | MEDIUM
-- Question: What is the average Diabetes_Risk_Score
-- for each medication-adherence category?
-- Concept: GROUP BY with AVG
-- ============================================================
SELECT
    Medication_Adherence,
    ROUND(AVG(Diabetes_Risk_Score), 2) AS average_risk_score
FROM diabetes_risk_prediction
GROUP BY Medication_Adherence
ORDER BY average_risk_score DESC;

-- ======================= DIFFICULT ===========================

-- ============================================================
-- Q71 | PERSPECTIVE 5 | DIFFICULT
-- Question: How can patients requiring a doctor consultation
-- be ranked according to their Diabetes_Risk_Score?
-- Concept: DENSE_RANK window function
-- ============================================================
SELECT
    Patient_ID,
    Doctor_Consultation_Needed,
    Diabetes_Risk_Score,
    Diabetes_Risk,
    DENSE_RANK() OVER (
        ORDER BY Diabetes_Risk_Score DESC
    ) AS risk_score_rank
FROM diabetes_risk_prediction
WHERE Doctor_Consultation_Needed = 'Yes'
ORDER BY risk_score_rank, Patient_ID;

-- ============================================================
-- Q72 | PERSPECTIVE 5 | DIFFICULT
-- Question: Within each diabetes-risk category, how can patients
-- be ranked according to their Diabetes_Risk_Score?
-- Concept: DENSE_RANK with PARTITION BY
-- ============================================================
SELECT
    Patient_ID,
    Diabetes_Risk,
    Diabetes_Risk_Score,
    DENSE_RANK() OVER (
        PARTITION BY Diabetes_Risk
        ORDER BY Diabetes_Risk_Score DESC
    ) AS risk_score_rank
FROM diabetes_risk_prediction
ORDER BY Diabetes_Risk, risk_score_rank, Patient_ID;

-- ============================================================
-- REUSABLE AI HEALTH RECOMMENDATION SUMMARY VIEW
-- Used by Q73 and Q75
-- ============================================================
CREATE OR REPLACE VIEW vw_ai_recommendation_summary AS
SELECT
    AI_Health_Recommendation,
    COUNT(*) AS patient_count,
    AVG(Diabetes_Risk_Score) AS average_risk_score
FROM diabetes_risk_prediction
GROUP BY AI_Health_Recommendation;

-- ============================================================
-- Q73 | PERSPECTIVE 5 | DIFFICULT
-- Question: Which AI health recommendations have an average
-- Diabetes_Risk_Score greater than the overall average
-- Diabetes_Risk_Score?
-- Concept: VIEW with WHERE filtering and scalar subquery
-- ============================================================
SELECT
    AI_Health_Recommendation,
    ROUND(average_risk_score, 2) AS average_risk_score
FROM vw_ai_recommendation_summary
WHERE average_risk_score > (
    SELECT AVG(Diabetes_Risk_Score)
    FROM diabetes_risk_prediction
)
ORDER BY average_risk_score DESC;

-- ============================================================
-- Q74 | PERSPECTIVE 5 | DIFFICULT
-- Question: Which patients requiring a doctor consultation have
-- a Diabetes_Risk_Score greater than the average score of all
-- patients requiring consultation?
-- Concept: Scalar subquery with WHERE
-- ============================================================
SELECT
    Patient_ID,
    Doctor_Consultation_Needed,
    Diabetes_Risk_Score,
    Diabetes_Risk
FROM diabetes_risk_prediction
WHERE Doctor_Consultation_Needed = 'Yes'
  AND Diabetes_Risk_Score > (
      SELECT AVG(Diabetes_Risk_Score)
      FROM diabetes_risk_prediction
      WHERE Doctor_Consultation_Needed = 'Yes'
  )
ORDER BY Diabetes_Risk_Score DESC, Patient_ID;

-- ============================================================
-- Q75 | PERSPECTIVE 5 | DIFFICULT
-- Question: How can AI health recommendations be ranked according
-- to both their average Diabetes_Risk_Score and the number of
-- patients receiving each recommendation?
-- Concept: VIEW with multiple DENSE_RANK window functions
-- ============================================================
SELECT
    AI_Health_Recommendation,
    patient_count,
    ROUND(average_risk_score, 2) AS average_risk_score,
    DENSE_RANK() OVER (
        ORDER BY average_risk_score DESC
    ) AS risk_score_rank,
    DENSE_RANK() OVER (
        ORDER BY patient_count DESC
    ) AS patient_count_rank
FROM vw_ai_recommendation_summary
ORDER BY
    risk_score_rank,
    patient_count_rank,
    AI_Health_Recommendation;

-- ============================================================
-- END OF SQL PRACTICAL EXAMINATION
-- TOTAL ANALYTICAL QUESTIONS: 75
-- ============================================================