-- Analyst Builder - Questions (free)
-- **********************************
-- https://www.analystbuilder.com/questions

-- 1. Difficulty: Easy		(11 Questions)
-- 2. Difficulty: Moderate	(12 Questions)
-- 3. Difficulty: Hard		( 3 Questions)



-- 1. Difficulty: Easy
-- *******************

-- 1.1 Tesla Models
-- https://www.analystbuilder.com/questions/tesla-models-soJdJ

-- Determine which Tesla Model has made the most profit.
-- Include all columns with the "profit" column at the end.

SELECT
	*,
	(car_price - production_cost) * cars_sold AS profit
FROM tesla_models
ORDER BY profit DESC
LIMIT 1;



-- 1.2 Heart Attack Risk
-- https://www.analystbuilder.com/questions/heart-attack-risk-FKfdn

-- If a patient is over the age of 50, cholesterol level of 240 or over, and weight 200 or greater, then they are at high risk of having a heart attack.
-- Write a query to retrieve these patients. Include all columns in your output.
-- As Cholesterol level is the largest indicator, order the output by Cholesterol from Highest to Lowest so he can reach out to them first.

SELECT *
FROM patients
WHERE age > 50 AND cholesterol >= 240 AND weight >= 200
ORDER BY cholesterol DESC;



-- 1.3 Apply Discount
-- https://www.analystbuilder.com/questions/apply-discount-RdWhb

-- A Computer store is offering a 25% discount for all new customers over the age of 65 or customers that spend more than $200 on their first purchase.
-- The owner wants to know how many customers received that discount since they started the promotion.
-- Write a query to see how many customers received that discount.

SELECT COUNT(customer_id)		-- or:  SELECT COUNT(*)
FROM customers
WHERE age > 65 OR total_purchase > 200;



-- 1.4 Million Dollar Store
-- https://www.analystbuilder.com/questions/million-dollar-store-ARdQa

-- Write a query that returns all of the stores whose average yearly revenue is greater than one million dollars.
-- Output the store ID and average revenue. Round the average to 2 decimal places.
-- Order by store ID.

SELECT
	store_id,
	ROUND(AVG(revenue), 2) AS avg_revenue
FROM stores
GROUP BY store_id
HAVING AVG(revenue) > 1000000
ORDER BY store_id;



-- 1.5 Chocolate
-- https://www.analystbuilder.com/questions/chocolate-vPiUY

-- Write a Query to return bakery items that contain the word "Chocolate".

SELECT * 
FROM bakery_items
WHERE product_name LIKE '%chocolate%';



-- 1.6 On The Way Out
-- https://www.analystbuilder.com/questions/on-the-way-out-LGNoQ

-- Write a query to identify the IDs of the three oldest employees.
-- Order output from oldest to youngest.

SELECT employee_id
FROM employees
ORDER BY birth_date ASC
LIMIT 3;



-- 1.7 Sandwich Generation
-- https://www.analystbuilder.com/questions/sandwich-generation-excIi

-- Below we have 2 tables, bread and meats.
-- Output every possible combination of bread and meats.
-- Order by the bread and then meat alphabetically.

SELECT
	bread_name,
	meat_name
FROM bread_table
CROSS JOIN meat_table
ORDER BY bread_name, meat_name;



-- 1.8 Electric Bike Replacement
-- https://www.analystbuilder.com/questions/electric-bike-replacement-ZaFie

-- After about 10,000 miles, Electric bike batteries begin to degrade and need to be replaced.
-- Write a query to determine the amount of bikes that currently need to be replaced.

SELECT COUNT(bike_id)		-- or: SELECT COUNT(*)
FROM bikes
WHERE miles > 10000;



-- 1.9 Car Failure
-- https://www.analystbuilder.com/questions/car-failure-TUsTW

-- Cars need to be inspected every year in order to pass inspection and be street legal.
-- If a car has any critical issues it will fail inspection or if it has more than 3 minor issues it will also fail.
-- Write a query to identify all of the cars that passed inspection.
-- Output should include the owner name and vehicle name. Order by the owner name alphabetically.

SELECT
	owner_name,
	vehicle
FROM inspections
WHERE critical_issues = 0 AND minor_issues <= 3
ORDER BY owner_name;



-- 1.10 Perfect Data Analyst
-- https://www.analystbuilder.com/questions/perfect-data-analyst-GMFmx

-- Return all the candidate IDs that have problem solving skills, SQL experience, knows Python or R, and has domain knowledge.
-- Order output on IDs from smallest to largest.

SELECT candidate_id
FROM candidates
WHERE   problem_solving = 'X'
	AND	sql_experience = 'X'
	AND	(python = 'X' OR r_programming = 'X')
	AND	domain_knowledge = 'X'
ORDER BY candidate_id;



-- 1.11 Costco Rotisserie Loss
-- https://www.analystbuilder.com/questions/costco-rotisserie-loss-kkCDh

-- Using the sales table, calculate how much money they have lost on their rotisserie chickens this year. Round to the nearest whole number.

SELECT ROUND(SUM(lost_revenue_millions)) AS Total_loss
FROM sales;





-- 2. Difficulty: Moderate
-- ***********************

-- 2.1 Senior Citizen Discount
-- https://www.analystbuilder.com/questions/senior-citizen-discount-fRxVJ

-- If a customer is 55 or above they qualify for the senior citizen discount. Check which customers qualify.
-- Assume the current date 1/1/2023.
-- Return all of the Customer IDs who qualify for the senior citizen discount in ascending order.

SELECT customer_id
FROM customers
WHERE TIMESTAMPDIFF(YEAR, birth_date, '2023-01-01') >= 55
ORDER BY customer_id;



-- 2.2 LinkedIn Famous
-- https://www.analystbuilder.com/questions/linkedin-famous-oQMdb

-- Write a query to determine the popularity of a post on LinkedIn.
-- Popularity is defined by number of actions (likes, comments, shares, etc.) divided by the number impressions the post received * 100.
-- If the post receives a score higher than 1 it was very popular.
-- Return all the post IDs and their popularity where the score is 1 or greater.
-- Order popularity from highest to lowest.

SELECT
	post_id,
	(actions / impressions * 100) AS popularity
FROM linkedin_posts
WHERE (actions / impressions * 100) >= 1
ORDER BY popularity DESC;



-- 2.3 Company Wide Increase
-- https://www.analystbuilder.com/questions/company-wide-increase-TytwW

-- If our company hits its yearly targets, every employee receives a salary increase depending on what Level you are in the company.
-- Give each employee who is a Level 1 a 10% increase, Lvel 2 a 15% increase, and Level 3 a 200% increase.
-- Include this new column in your output as "new_salary" along with your other columns.

SELECT
	*,
	CASE pay_level
		WHEN 1 THEN salary * 1.1
		WHEN 2 THEN salary * 1.15
		WHEN 3 THEN salary * 3
		ELSE salary
	END AS new_salary
FROM employees;



-- 2.4 Media Addicts
-- https://www.analystbuilder.com/questions/media-addicts-deISZ

-- Write a query to find the people who spent a higher than average amount of time on social media.
-- Provide just their first names alphabetically so we can reach out to them individually.

WITH cte_uid AS
(
SELECT user_id
FROM user_time
WHERE media_time_minutes > (SELECT AVG(media_time_minutes) FROM user_time)
)
SELECT first_name
FROM users
JOIN cte_uid
	ON users.user_id = cte_uid.user_id
ORDER BY first_name;

-- Alternative code:  ... WHERE user_id IN (SELECT ...)



-- 2.5 Bike Price
-- https://www.analystbuilder.com/questions/bike-price-zKcOR

-- Sarah's Bike Shop sells a lot of bikes and wants to know what the average sale price is of her bikes.
-- She sometimes gives away a bike for free for a charity event and if she does she leaves the price of the bike as blank, but marks it sold.
-- Write a query to show her the average sale price of bikes for only bikes that were sold, and not donated.
-- Round answer to 2 decimal places.

SELECT ROUND(AVG(bike_price), 2) AS avg_bike_price
FROM inventory
WHERE bike_price IS NOT NULL AND bike_sold = 'Y';



-- 2.6 Direct Reports
-- https://www.analystbuilder.com/questions/direct-reports-qQoVA

-- Write a query to determine how many direct reports each Manager has.
-- Note: Managers will have "Manager" in their title.
-- Report the Manager ID, Manager Title, and the number of direct reports in your output.

SELECT
	dr_m.employee_id AS manager_id,
	dr_m.position    AS manager_position,
	COUNT(*)         AS direct_reports
FROM direct_reports AS dr_e
JOIN direct_reports AS dr_m
	ON dr_e.managers_id = dr_m.employee_id
WHERE dr_m.position LIKE '%Manager%'
GROUP BY manager_id;



-- 2.7 Food Divides Us
-- https://www.analystbuilder.com/questions/food-divides-us-GvhLL

-- Write a query to determine which region spends the most amount of money on fast food.

SELECT region
FROM food_regions
GROUP BY region
ORDER BY SUM(fast_food_millions) DESC
LIMIT 1;

-- Alternative code:  Using a CTE ...



-- 2.8 Kroger's Members
-- https://www.analystbuilder.com/questions/krogers-members-FjyKN

-- Write a query to find the percentage of customers who shop at Kroger's who also have a Kroger's membership card. Round to 2 decimal places.

SELECT
	ROUND(COUNT(has_member_card) / (SELECT COUNT(*) FROM customers) * 100, 2) AS percentage
FROM customers
WHERE has_member_card = 'Y';



-- 2.9 Tech Layoffs
-- https://www.analystbuilder.com/questions/tech-layoffs-CpLXE

-- Write a query to determine the percentage of employees that were laid off from each company.
-- Output should include the company and the percentage (to 2 decimal places) of laid off employees.
-- Order by company name alphabetically.

SELECT
	company,
	ROUND(employees_fired / company_size * 100, 2) AS Percentage_Laid_Off
FROM tech_layoffs
ORDER BY company;



-- 2.10 Separation
-- https://www.analystbuilder.com/questions/separation-DbHMu

-- Data was input incorrectly into the database. The ID was combined with the First Name.
-- Write a query to separate the ID and First Name into two separate columns.
-- Each ID is 5 characters long.

SELECT
	LEFT(id, 5)   AS ID,
	SUBSTR(id, 6) AS First_Name
FROM bad_data;



-- 2.11 TMI (Too Much Information)
-- https://www.analystbuilder.com/questions/tmi-too-much-information-VyNhZ

-- Here you are given a table that contains a customer ID and their full name.
-- Return the customer ID with only the first name of each customer.

SELECT
	customer_id,
	SUBSTRING_INDEX(full_name, ' ', 1) AS first_name
FROM customers;



-- 2.12 Shrink-flation
-- https://www.analystbuilder.com/questions/shrink-flation-ohNJw

-- Write a query to identify products that have undergone shrink-flation over the last year.
-- Shrink-flation is defined as a reduction in product size while maintaining or increasing the price.
-- Include a flag for Shrinkflation. This should be a boolean value (True or False) indicating whether the product has undergone shrink-flation.
-- The output should have the columns Product_Name, Size_Change_Percentage, Price_Change_Percentage, and Shrinkflation_Flag.
-- Round percentages to the nearest whole number and order the output on the product names alphabetically.

SELECT
	product_name,
	ROUND((new_size  - original_size ) / original_size  * 100) AS  size_change_percentage,
	ROUND((new_price - original_price) / original_price * 100) AS price_change_percentage,
	CASE
		WHEN new_size < original_size AND new_price >= original_price THEN 'True'
		ELSE 'False'
	END AS shrinkflation_flag
FROM products
ORDER BY product_name;





-- 3. Difficulty: Hard
-- *******************

-- 3.1 Temperature Fluctuations
-- https://www.analystbuilder.com/questions/temperature-fluctuations-ftFQu

-- Write a query to find all dates with higher temperatures compared to the previous dates (yesterday).
-- Order dates in ascending order.

SELECT
	t1.date AS date_higher_t
FROM temperatures AS t1
JOIN temperatures AS t2
	ON t1.date = ADDDATE(t2.date, 1)
WHERE t1.temperature > t2.temperature
ORDER BY date_higher_t;



-- 3.2 Cake vs Pie
-- https://www.analystbuilder.com/questions/cake-vs-pie-rSDbF

-- Marcie's Bakery is having a contest at her store. Whichever dessert sells more each day will be on discount tomorrow.
-- She needs to identify which dessert is selling more.
-- Write a query to report the difference between the number of Cakes and Pies sold each day.
-- Output should include the date sold, the difference between cakes and pies, and which one sold more (cake or pie).
-- The difference should be a positive number.
-- Return the result table ordered by Date_Sold.
-- Columns in output should be date_sold, difference, and sold_more.

SELECT
	d1.date_sold,
	ABS(IFNULL(d1.amount_sold, 0) - IFNULL(d2.amount_sold, 0)) AS difference,
	CASE
		WHEN IFNULL(d1.amount_sold, 0) > IFNULL(d2.amount_sold, 0) THEN d1.product
		WHEN IFNULL(d1.amount_sold, 0) < IFNULL(d2.amount_sold, 0) THEN d2.product
		ELSE 'Equal'
	END AS sold_more
FROM desserts AS d1
JOIN desserts AS d2
	ON d1.date_sold = d2.date_sold
	AND d1.product = 'Cake'
	AND d2.product = 'Pie'
ORDER BY d1.date_sold;



-- 3.3 Kelly's 3rd Purchase
-- https://www.analystbuilder.com/questions/kellys-3rd-purchase-kFaIE

-- At Kelly's Ice Cream Shop, Kelly gives a 33% discount on each customer's 3rd purchase.
-- Write a query to select the 3rd transaction for each customer that received that discount.
-- Output the customer id, transaction id, amount, and the amount after the discount as "discounted_amount".
-- Order output on customer ID in ascending order.
-- Note: Transaction IDs occur sequentially. The lowest transaction ID is the earliest ID.

WITH cte_row_n AS
(
SELECT
	*,
	ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY transaction_id) AS row_n
FROM purchases
)
SELECT
	customer_id,
	transaction_id,
	amount,
	amount * 0.67 AS discounted_amount
FROM cte_row_n
WHERE row_n = 3
ORDER BY customer_id;
