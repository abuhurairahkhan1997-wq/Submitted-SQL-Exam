# Diabetes Risk Analysis (SQL)

PGDA 0526 exam submission – Phase 2, SQL project (Skill Versed). Submitted October 2026.

## Files
- `PGDA0526_Diabetes_SQL_Project.sql` – all 75 queries
- `SQL_Report.docx` – project report with results

## Dataset
- Diabetes risk prediction dataset, 50,000 patients, 41 columns
- The dataset is not included in this repository. Import it into a MySQL table named `diabetes_risk_prediction` before running the script.

## What I did
- Answered 75 questions across five areas: demographics, clinical measures, lifestyle, medical history and prevention
- Used filtering, GROUP BY and HAVING, subqueries, CTEs, a view and window functions (DENSE_RANK)

## Key findings
- Average HbA1c rose clearly with risk level: 5.67 (Low), 7.54 (Moderate), 8.86 (High)
- Blood glucose barely differed between risk levels
- Patients with hypertension had a higher average risk score (76.98) than those without (71.06)

## Tools
MySQL, MySQL Workbench
