-- MySQL Lessons
-- Level 1 - Beginners
-- *******************

-- https://www.youtube.com/@AlexTheAnalyst/videos

-- 1.1. Create a local training Database & Tables
-- 1.2. SELECT Statement
-- 1.3. WHERE Clause
-- 1.4. GROUP BY and ORDER BY
-- 1.5. HAVING vs. WHERE
-- 1.6. LIMIT and Aliasing

-- **********************************************


-- 1.1. Create a local training Database & Tables
-- Guiding video:  https://www.youtube.com/watch?v=wgRwITQHszU

DROP DATABASE IF EXISTS `Parks_and_Recreation`;
CREATE DATABASE `Parks_and_Recreation`;
USE `Parks_and_Recreation`;

CREATE TABLE employee_demographics (
  employee_id INT NOT NULL,
  first_name VARCHAR(50),
  last_name VARCHAR(50),
  age INT,
  gender VARCHAR(10),
  birth_date DATE,
  PRIMARY KEY (employee_id)
);

CREATE TABLE employee_salary (
  employee_id INT NOT NULL,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  occupation VARCHAR(50),
  salary INT,
  dept_id INT
);

INSERT INTO employee_demographics (employee_id, first_name, last_name, age, gender, birth_date)
VALUES
(1, 'Leslie', 'Knope', 44, 'Female','1979-09-25'),
(3, 'Tom', 'Haverford', 36, 'Male', '1987-03-04'),
(4, 'April', 'Ludgate', 29, 'Female', '1994-03-27'),
(5, 'Jerry', 'Gergich', 61, 'Male', '1962-08-28'),
(6, 'Donna', 'Meagle', 46, 'Female', '1977-07-30'),
(7, 'Ann', 'Perkins', 35, 'Female', '1988-12-01'),
(8, 'Chris', 'Traeger', 43, 'Male', '1980-11-11'),
(9, 'Ben', 'Wyatt', 38, 'Male', '1985-07-26'),
(10, 'Andy', 'Dwyer', 34, 'Male', '1989-03-25'),
(11, 'Mark', 'Brendanawicz', 40, 'Male', '1983-06-14'),
(12, 'Craig', 'Middlebrooks', 37, 'Male', '1986-07-27');

INSERT INTO employee_salary (employee_id, first_name, last_name, occupation, salary, dept_id)
VALUES
(1, 'Leslie', 'Knope', 'Deputy Director of Parks and Recreation', 75000, 1),
(2, 'Ron', 'Swanson', 'Director of Parks and Recreation', 70000, 1),
(3, 'Tom', 'Haverford', 'Entrepreneur', 50000, 1),
(4, 'April', 'Ludgate', 'Assistant to the Director of Parks and Recreation', 25000, 1),
(5, 'Jerry', 'Gergich', 'Office Manager', 50000, 1),
(6, 'Donna', 'Meagle', 'Office Manager', 60000, 1),
(7, 'Ann', 'Perkins', 'Nurse', 55000, 4),
(8, 'Chris', 'Traeger', 'City Manager', 90000, 3),
(9, 'Ben', 'Wyatt', 'State Auditor', 70000, 6),
(10, 'Andy', 'Dwyer', 'Shoe Shiner and Musician', 20000, NULL),
(11, 'Mark', 'Brendanawicz', 'City Planner', 57000, 3),
(12, 'Craig', 'Middlebrooks', 'Parks Director', 65000, 1);

CREATE TABLE parks_departments (
  department_id INT NOT NULL AUTO_INCREMENT,
  department_name varchar(50) NOT NULL,
  PRIMARY KEY (department_id)
);

INSERT INTO parks_departments (department_name)
VALUES
('Parks and Recreation'),
('Animal Control'),
('Public Works'),
('Healthcare'),
('Library'),
('Finance');


-- Added later by Martin M. - To add a new column and calculate the real age as of the current date

TABLE employee_demographics;

ALTER TABLE employee_demographics
MODIFY COLUMN age INT AFTER birth_date;

ALTER TABLE employee_demographics
RENAME COLUMN age TO age_orig,
ADD COLUMN age_real INT;

UPDATE employee_demographics
SET age_real = TIMESTAMPDIFF(YEAR, birth_date, CURRENT_DATE());

TABLE employee_demographics;


-- 1.2. SELECT Statement
-- Guiding video:  https://www.youtube.com/watch?v=HYD8KjPB9F8

SELECT * 
FROM employee_demographics;

SELECT first_name, last_name, birth_date, age_orig, (age_orig + 10) * 10
FROM employee_demographics;


-- SELECT DISTINCT

SELECT DISTINCT gender
FROM employee_demographics;

SELECT DISTINCT first_name, gender
FROM employee_demographics;


-- 1.3. WHERE Clause
-- Guiding video:  https://www.youtube.com/watch?v=MARn_mssG4A

-- SELECT ... WHERE ...

SELECT * 
FROM employee_salary
WHERE first_name = 'Leslie';

SELECT * 
FROM employee_salary
WHERE salary >= 50000;


-- WHERE ... BETWEEN ... AND ...

SELECT * 
FROM employee_salary
WHERE salary BETWEEN 50000 AND 70000;

SELECT * 
FROM employee_demographics
WHERE age_orig BETWEEN 30 AND 40;


-- WHERE ... IN (..., ..., ...)

SELECT * 
FROM employee_salary
WHERE occupation IN ('Office Manager', 'Nurse', 'City Planner');


-- WHERE ... != ...
-- WHERE ... AND ...

SELECT * 
FROM employee_demographics
WHERE gender != 'Female';

SELECT * 
FROM employee_demographics
WHERE birth_date > '1985-01-01' AND gender = 'Male';


-- WHERE ... LIKE ...

SELECT * 
FROM employee_demographics
WHERE first_name LIKE 'A___%';

SELECT * 
FROM employee_demographics
WHERE birth_date LIKE '1989%';


-- 1.4. GROUP BY and ORDER BY
-- Guiding video:  https://www.youtube.com/watch?v=zgYqUP_PhQo

SELECT gender, AVG(age_orig), MAX(age_orig), MIN(age_orig), COUNT(age_orig)
FROM employee_demographics
GROUP BY gender;

SELECT occupation, salary
FROM employee_salary
GROUP BY occupation, salary;


SELECT * 
FROM employee_demographics
ORDER BY first_name DESC;

SELECT * 
FROM employee_demographics
ORDER BY gender, age_orig DESC;


-- 1.5. HAVING vs. WHERE
-- Guiding video:  https://www.youtube.com/watch?v=dCNjUOc1cBY

SELECT gender, AVG(age_orig)
FROM employee_demographics
GROUP BY gender;

SELECT gender, AVG(age_orig)
FROM employee_demographics
GROUP BY gender
HAVING AVG(age_orig) > 40;

SELECT occupation, AVG(salary)
FROM employee_salary
WHERE occupation LIKE '%Manager%'
GROUP BY occupation
HAVING AVG(salary) < 60000;


-- 1.6. LIMIT and Aliasing
-- Guiding video:  https://www.youtube.com/watch?v=ZnAydTqCtFU

SELECT * 
FROM employee_demographics
ORDER BY age_orig DESC
LIMIT 5;


SELECT gender, AVG(age_orig) AS avg_age
FROM employee_demographics
GROUP BY gender
HAVING avg_age > 40;

