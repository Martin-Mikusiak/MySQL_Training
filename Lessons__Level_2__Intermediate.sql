-- MySQL Lessons
-- Level 2 - Intermediate
-- **********************

-- 2.1. JOINs
-- 2.2. UNIONs
-- 2.3. String Functions
-- 2.4. CASE Statement
-- 2.5. Subqueries
-- 2.6. Window functions
-- ******************************************


-- 2.1. JOINs
-- Guiding video:  https://www.youtube.com/watch?v=lXQzD09BOH0

SELECT * 
FROM employee_demographics;

SELECT * 
FROM employee_salary;

SELECT * 
FROM parks_departments;


-- INNER JOIN ... ON ...

SELECT * 
FROM employee_demographics AS dem
INNER JOIN employee_salary AS sal
	ON dem.employee_id = sal.employee_id;

SELECT dem.employee_id, dem.first_name, dem.last_name, age_orig, gender, occupation, salary
FROM employee_demographics AS dem
INNER JOIN employee_salary AS sal
	ON dem.employee_id = sal.employee_id;


-- LEFT JOIN

SELECT *
FROM employee_demographics AS dem
LEFT JOIN employee_salary AS sal
	ON dem.employee_id = sal.employee_id;


-- RIGHT JOIN

SELECT *
FROM employee_demographics AS dem
RIGHT JOIN employee_salary AS sal
	ON dem.employee_id = sal.employee_id;


-- Self JOIN
-- Example: "santa"

SELECT emp1.employee_id AS emp_id_santa,
emp1.first_name AS first_name_santa,
emp1.last_name AS last_name_santa,
emp2.employee_id AS emp_id,
emp2.first_name AS first_name_emp,
emp2.last_name AS last_name_emp
FROM employee_salary AS emp1
JOIN employee_salary AS emp2
	ON emp1.employee_id + 1 = emp2.employee_id;


-- JOIN-ing multiple tables together

SELECT * 
FROM employee_demographics AS dem
INNER JOIN employee_salary AS sal
	ON dem.employee_id = sal.employee_id
INNER JOIN parks_departments AS dpt
	ON sal.dept_id = dpt.department_id;


-- CROSS JOIN

SELECT employee_id, first_name, last_name, department_name
FROM employee_demographics
CROSS JOIN parks_departments
ORDER BY employee_id, department_name;


-- 2.2. UNIONs
-- Guiding video:  https://www.youtube.com/watch?v=iTQW_nDp938

SELECT * FROM employee_demographics;

SELECT * FROM employee_salary;


-- UNION [DISTINCT (default behavior)] / [ALL]

SELECT employee_id, first_name, last_name
FROM employee_demographics
UNION
SELECT employee_id, first_name, last_name
FROM employee_salary;

SELECT employee_id, first_name, last_name
FROM employee_demographics
UNION
SELECT employee_id, first_name, last_name
FROM employee_salary
ORDER BY employee_id;


SELECT employee_id, first_name, last_name, 'Old Man' AS label
FROM employee_demographics
WHERE age_orig > 40 AND gender = 'Male'
UNION
SELECT employee_id, first_name, last_name, 'Old Lady' AS label
FROM employee_demographics
WHERE age_orig > 40 AND gender = 'Female'
UNION
SELECT employee_id, first_name, last_name, 'Highly paid' AS label
FROM employee_salary
WHERE salary > 70000
ORDER BY employee_id;


-- 2.3. String Functions
-- Guiding video:  https://www.youtube.com/watch?v=KRXSJb9ql1Y

-- LENGTH()
SELECT first_name, LENGTH(first_name), last_name, LENGTH(last_name)
FROM employee_demographics
ORDER BY LENGTH(last_name), last_name;

-- UPPER(), LOWER()
SELECT first_name, UPPER(first_name), LOWER(first_name)
FROM employee_demographics;

-- TRIM(), LTRIM(), RTRIM() ...

-- LEFT(), RIGHT() ...

-- SUBSTRING()
SELECT birth_date, SUBSTRING(birth_date, 6, 2) AS birth_month
FROM employee_demographics;

-- Note by Martin M.
-- Better alternative for the previous task - The EXTRACT() function - to extract part of a date:
SELECT birth_date, EXTRACT(MONTH FROM birth_date) AS birth_month
FROM employee_demographics;


-- REPLACE()
SELECT first_name, REPLACE(first_name, 'a', 'x')
FROM employee_demographics;

-- LOCATE()
SELECT first_name, LOCATE('An', first_name)
FROM employee_demographics;

-- CONCAT()
SELECT first_name, last_name, CONCAT(first_name, ' ', last_name) AS full_name
FROM employee_demographics;

-- REVERSE()
SELECT first_name, REVERSE(first_name)
FROM employee_demographics;


-- 2.4. CASE Statement
-- Guiding video:  https://www.youtube.com/watch?v=RYIiOG4LsvQ

-- Show the age as a text description
SELECT 
    first_name,
    last_name,
    age_orig,
    CASE
        WHEN age_orig < 30              THEN 'Young'
        WHEN age_orig BETWEEN 30 AND 50 THEN 'Old'
        ELSE 'Very old'
    END AS age_text
FROM employee_demographics;


-- New salary - Increase of the salary & bonus
SELECT 
    first_name,
    last_name,
    salary,
    CASE
        WHEN salary <= 50000 THEN ROUND(salary * 1.05)
        WHEN salary >  50000 THEN ROUND(salary * 1.07)
    END AS new_salary,
    dept_id,
    CASE
        WHEN dept_id = 6 THEN ROUND(salary * .1)
        ELSE 0
    END AS bonus
FROM employee_salary;


-- 2.5. Subqueries
-- Guiding video:  https://www.youtube.com/watch?v=Vj6RqA_X-IE

SELECT *
FROM employee_demographics
WHERE employee_id IN
	(SELECT employee_id 
    FROM employee_salary 
    WHERE dept_id = 1);


SELECT first_name, last_name, salary,
	(SELECT ROUND(AVG(salary))
    FROM employee_salary) AS avg_salary
FROM employee_salary;


-- diff_avg_salary (for fun...)
SELECT first_name, last_name, salary,
	salary - (SELECT ROUND(AVG(salary)) FROM employee_salary) AS diff_avg_salary
FROM employee_salary;


-- diff_avg_salary - using CTE
WITH CTE_avg_sal (global_avg_sal) AS
(
	SELECT ROUND(AVG(salary)) FROM employee_salary
)
SELECT
	first_name,
    last_name,
    salary,
    (SELECT global_avg_sal FROM CTE_avg_sal) AS avg_sal,
    salary - (SELECT global_avg_sal FROM CTE_avg_sal) AS diff_avg_sal
FROM employee_salary;

--

SELECT 
	gender,
    AVG(age_orig) AS avg_age,
    MAX(age_orig) AS max_age,
    MIN(age_orig) AS min_age,
    COUNT(age_orig) AS cnt_age
FROM employee_demographics
GROUP BY gender;


-- Average of max age of female & male genders
SELECT AVG(max_age) AS avg_max_age
FROM
	(SELECT gender,	MAX(age_orig) AS max_age
	FROM employee_demographics
	GROUP BY gender) AS aggr_table
;


-- 2.6. Window functions
-- Guiding video:  https://www.youtube.com/watch?v=7NBt0V8ebGk

-- Version using GROUP BY ...
SELECT 
	gender, 
    ROUND(AVG(salary), 1) AS avg_salary
FROM employee_demographics AS dem
JOIN employee_salary AS sal
	ON dem.employee_id = sal.employee_id
GROUP BY gender;


-- Version using Window functions - OVER()
SELECT 
	dem.first_name, 
    dem.last_name, 
    gender, 
	AVG(salary) OVER(PARTITION BY gender) AS avg_salary_gender
FROM employee_demographics AS dem
JOIN employee_salary AS sal
	ON dem.employee_id = sal.employee_id;


SELECT 
	dem.employee_id, dem.first_name, dem.last_name, gender, salary,
	SUM(salary) OVER(PARTITION BY gender) AS sum_salary_gender
FROM employee_demographics AS dem
JOIN employee_salary AS sal
	ON dem.employee_id = sal.employee_id;


-- Rolling total
SELECT 
	dem.employee_id, dem.first_name, dem.last_name, gender, salary,
	SUM(salary) OVER(PARTITION BY gender ORDER BY dem.employee_id) AS rolling_total
FROM employee_demographics AS dem
JOIN employee_salary AS sal
	ON dem.employee_id = sal.employee_id;

-- ROW_NUMBER() OVER()
SELECT 
	dem.employee_id, dem.first_name, dem.last_name, gender, salary,
	ROW_NUMBER() OVER()
FROM employee_demographics AS dem
JOIN employee_salary AS sal
	ON dem.employee_id = sal.employee_id;


-- ROW_NUMBER() OVER(PARTITION BY ... ORDER BY ...)
-- RANK() ...
-- DENSE_RANK() ...
SELECT 
	dem.employee_id, dem.first_name, dem.last_name, gender, salary,
	ROW_NUMBER() OVER(PARTITION BY gender ORDER BY salary DESC) AS row_num,
	RANK()       OVER(PARTITION BY gender ORDER BY salary DESC) AS rank_num,
	DENSE_RANK() OVER(PARTITION BY gender ORDER BY salary DESC) AS dense_rank_num
FROM employee_demographics AS dem
JOIN employee_salary AS sal
	ON dem.employee_id = sal.employee_id;


