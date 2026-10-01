CREATE DATABASE hr_attrition;

USE hr_attrition;

SELECT 
    COUNT(*) AS performance_records,
    COUNT(DISTINCT p.EmployeeID) AS employees_with_reviews
FROM performance_rating p;

SELECT COUNT(*) AS invalid_employee_ids
FROM performance_rating p
LEFT JOIN employee e
    ON p.EmployeeID = e.EmployeeID
WHERE e.EmployeeID IS NULL;


-- Query 1 — Overall Attrition Analysis

-- Purpose: Find the total number of employees
SELECT COUNT(*) AS total_employees
FROM employee;

-- Purpose: Find how many employees left the organization.
SELECT COUNT(*) AS employees_left
FROM employee
WHERE Attrition = 'Yes';

-- Find how many employees stayed.
SELECT COUNT(*) AS employees_stayed
FROM employee
WHERE Attrition = 'No';

-- Overall Attrition Rate
SELECT 
    ROUND(
        COUNT(CASE WHEN Attrition = 'Yes' THEN 1 END) * 100.0 
        / COUNT(*),
        2
    ) AS attrition_rate
FROM employee;

-- Query 2.1 — Attrition by Department

-- purpose: Identify which departments have the largest number of employees leaving
SELECT
    Department,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left
FROM employee
GROUP BY Department
ORDER BY employees_left DESC;


-- Query 2.2 — Department-wise Attrition Rate

-- Business question:Which department has the highest employee attrition rate?
SELECT
    Department,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left,
    ROUND(
        SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS attrition_rate
FROM employee
GROUP BY Department
ORDER BY attrition_rate DESC;

-- Query 3.1 — Attrition by Job Role
-- Business purpose: Identify the job roles contributing the most to employee attrition.
SELECT
    JobRole,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left
FROM employee
GROUP BY JobRole
ORDER BY employees_left DESC;

-- Query 3.2 — Job Role Attrition Rate
-- Business question: Which job roles have the highest attrition rate?
SELECT
    JobRole,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left,
    ROUND(
        SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS attrition_rate
FROM employee
GROUP BY JobRole
ORDER BY attrition_rate DESC;

-- Query 4 — Attrition by Age Group
-- Business question: Which age group has the highest attrition rate?
SELECT
    AgeGroup,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left,
    ROUND(
        SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS attrition_rate
FROM employee
GROUP BY AgeGroup
ORDER BY attrition_rate DESC;

-- Query 5 — Attrition by Overtime
-- Business question: Do employees working overtime have a higher attrition rate than employees who do not?
SELECT
    OverTime,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left,
    ROUND(
        SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS attrition_rate
FROM employee
GROUP BY OverTime
ORDER BY attrition_rate DESC;

-- Query 6 — Attrition by Salary Band
-- Business question: Which salary band has the highest attrition rate?
SELECT
    SalaryBand,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left,
    ROUND(
        SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS attrition_rate
FROM employee
GROUP BY SalaryBand
ORDER BY attrition_rate DESC;


-- Query 7 — Attrition by Tenure Group
-- Business question: Which tenure group has the highest attrition rate?
SELECT
    TenureGroup,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left,
    ROUND(
        SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS attrition_rate
FROM employee
GROUP BY TenureGroup
ORDER BY attrition_rate DESC;

-- Query 8 — Attrition by Promotion Gap
-- Business question: Does a longer gap since the last promotion correspond to a higher attrition rate?
SELECT
    PromotionGapGroup,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left,
    ROUND(
        SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS attrition_rate
FROM employee
GROUP BY PromotionGapGroup
ORDER BY attrition_rate DESC;

-- Query 9 — Employee-Level Job Satisfaction
-- Business question: Among employees with a recorded performance review, how does job satisfaction relate to attrition?
WITH latest_review AS (
    SELECT
        p.*,
        ROW_NUMBER() OVER (
            PARTITION BY EmployeeID
            ORDER BY ReviewDate DESC
        ) AS rn
    FROM performance_rating p
)
SELECT
    p.JobSatisfaction,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN e.Attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left,
    ROUND(
        SUM(CASE WHEN e.Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS attrition_rate
FROM employee e
JOIN latest_review p
    ON e.EmployeeID = p.EmployeeID
WHERE p.rn = 1
GROUP BY p.JobSatisfaction
ORDER BY attrition_rate DESC;

-- Query 10 — Attrition by Work-Life Balance
-- Business question: Is work-life balance associated with employee attrition?
WITH latest_review AS (
    SELECT
        p.*,
        ROW_NUMBER() OVER (
            PARTITION BY EmployeeID
            ORDER BY ReviewDate DESC
        ) AS rn
    FROM performance_rating p
)
SELECT
    p.WorkLifeBalance,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN e.Attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left,
    ROUND(
        SUM(CASE WHEN e.Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS attrition_rate
FROM employee e
JOIN latest_review p
    ON e.EmployeeID = p.EmployeeID
WHERE p.rn = 1
GROUP BY p.WorkLifeBalance
ORDER BY attrition_rate DESC;

-- Query 11 — Attrition by Business Travel
-- Business question: Does frequent business travel correspond to a higher attrition rate?
SELECT
    BusinessTravel,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left,
    ROUND(
        SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS attrition_rate
FROM employee
GROUP BY BusinessTravel
ORDER BY attrition_rate DESC;

-- Query 12 — Attrition by Distance Group
-- Business question: Does commuting distance appear to be associated with employee attrition?
SELECT
    DistanceGroup,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left,
    ROUND(
        SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS attrition_rate
FROM employee
GROUP BY DistanceGroup
ORDER BY attrition_rate DESC;


-- Query 13 — Performance vs Attrition\
-- Business question: Is employee performance associated with attrition?
-- Query 13 - Attrition by Performance Score

WITH latest_review AS (
    SELECT
        p.*,
        ROW_NUMBER() OVER (
            PARTITION BY EmployeeID
            ORDER BY ReviewDate DESC
        ) AS rn
    FROM performance_rating p
)
SELECT
    p.OverallPerformanceScore,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN e.Attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left,
    ROUND(
        SUM(CASE WHEN e.Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS attrition_rate
FROM employee e
JOIN latest_review p
    ON e.EmployeeID = p.EmployeeID
WHERE p.rn = 1
GROUP BY p.OverallPerformanceScore
ORDER BY p.OverallPerformanceScore;
