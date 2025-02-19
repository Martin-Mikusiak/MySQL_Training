-- MySQL Lessons
-- Level 3 - Advanced
-- ******************

-- 3.1. CTEs (Common Table Expressions)
-- 3.2. Temporary Tables
-- 3.3. Stored Procedures
-- 3.4. Triggers and Events
-- ************************************


-- 3.1. CTEs (Common Table Expressions)
-- Guiding video:  https://www.youtube.com/watch?v=UC7uvOqcUTs

-- A Common Table Expression (CTE) is a named temporary result set that exists within the scope of a single statement
-- and that can be referred to later within that statement, possibly multiple times.

-- Source query
SELECT gender, ROUND(AVG(salary), 1) AS avg_sal, MAX(salary) AS max_sal, MIN(salary) AS min_sal, COUNT(salary) AS cnt_sal
FROM employee_demographics AS dem
JOIN employee_salary AS sal
	ON dem.employee_id = sal.employee_id
GROUP BY gender;


-- CTE
WITH CTE_Example (gender, avg_sal, max_sal, min_sal, cnt_sal) AS
(
	SELECT gender, ROUND(AVG(salary), 1), MAX(salary), MIN(salary), COUNT(salary)
	FROM employee_demographics AS dem
	JOIN employee_salary AS sal
		ON dem.employee_id = sal.employee_id
	GROUP BY gender
)
SELECT *
FROM CTE_Example;


-- Average of Female & Male average salaries
WITH CTE_Example (gender, avg_sal) AS
(
	SELECT gender, ROUND(AVG(salary), 1)
	FROM employee_demographics AS dem
	JOIN employee_salary AS sal
		ON dem.employee_id = sal.employee_id
	GROUP BY gender
)
SELECT ROUND(AVG(avg_sal), 1) AS avg_f_m_sal
FROM CTE_Example;


-- Multiple CTEs
WITH
CTE_Example_1 AS
(
	SELECT employee_id, gender, birth_date, first_name, last_name
	FROM employee_demographics AS dem
	WHERE birth_date > '1985-01-01'
),
CTE_Example_2 AS
(
	SELECT employee_id, salary
	FROM employee_salary AS sal
	WHERE salary >= 50000
)
SELECT *
FROM CTE_Example_1
JOIN CTE_Example_2
	ON CTE_Example_1.employee_id = CTE_Example_2.employee_id;


-- 3.2. Temporary Tables
-- Guiding video:  https://www.youtube.com/watch?v=uEk07jXdKOo

-- Variant #1 - CREATE ... & INSERT INTO ...

CREATE TEMPORARY TABLE Temp_table_1
(
	first_name VARCHAR(50),
    last_name  VARCHAR(50),
    fav_movie  VARCHAR(100)
);

INSERT INTO Temp_table_1 VALUES
(
	'Jozko', 'Mrkvicka', 'Avatar'
);

SELECT *
FROM Temp_table_1;


-- Variant #2 - CREATE ... & SELECT ... WHERE ....

CREATE TEMPORARY TABLE tt_sal_over_50k
SELECT *
FROM employee_salary
WHERE salary >= 50000;

SELECT *
FROM tt_sal_over_50k;


-- 3.3. Stored Procedures
-- Guiding video:  https://www.youtube.com/watch?v=7vnxpcqmqNQ

CREATE PROCEDURE p_salaries_over_50k()
SELECT * 
FROM employee_salary
WHERE salary >= 50000;

CALL p_salaries_over_50k();


-- More queries in one Stored procedure

DELIMITER $$
CREATE PROCEDURE p_salaries_more_queries()
BEGIN
	SELECT * 
	FROM employee_salary
	WHERE salary >= 50000;
    SELECT * 
	FROM employee_salary
	WHERE salary >= 10000;
END $$
DELIMITER ;

CALL p_salaries_more_queries();


-- Stored Procedures with parameters

DELIMITER $$
CREATE PROCEDURE p_salary_param(p_emp_id INT)
BEGIN
	SELECT salary
	FROM employee_salary
	WHERE employee_id = p_emp_id;
END $$
DELIMITER ;

CALL p_salary_param(1);


-- 3.4. Triggers and Events
-- Guiding video:  https://www.youtube.com/watch?v=QMUZ5HfWMRc

SELECT * 
FROM employee_demographics;

SELECT * 
FROM employee_salary;


-- CREATE TRIGGER

DELIMITER $$
CREATE TRIGGER employee_insert
	AFTER INSERT ON employee_salary
    FOR EACH ROW 
BEGIN
	INSERT INTO employee_demographics (employee_id, first_name, last_name)
    VALUES (NEW.employee_id, NEW.first_name, NEW.last_name);
END $$
DELIMITER ;

INSERT INTO employee_salary (employee_id, first_name, last_name, occupation, salary, dept_id)
VALUES (13, 'Jean', 'Saperstein', 'Entertainment CEO', 100000, NULL);


-- CREATE EVENT

DELIMITER $$
CREATE EVENT delete_retirees
ON SCHEDULE EVERY 30 SECOND
DO
BEGIN
	DELETE
    FROM employee_demographics
    WHERE age_orig > 60;
END $$
DELIMITER ;


SHOW EVENTS;

ALTER EVENT delete_retirees
ON SCHEDULE EVERY 1 MONTH;

ALTER EVENT delete_retirees
DISABLE;

DROP EVENT IF EXISTS delete_retirees;

