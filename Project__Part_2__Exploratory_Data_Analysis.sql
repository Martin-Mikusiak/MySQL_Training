-- MySQL Project - Part 2 - Exploratory Data Analysis
-- **************************************************

-- Links
-- Dataset:        See Part 1 - Data Cleaning
-- Guiding video:  https://www.youtube.com/watch?v=QYd-RtK58VQ


TABLE layoffs_staging_2;

SELECT 
	MAX(total_laid_off),		-- Result: 12000
	MAX(pct_laid_off),			-- Result: 1.00
	MIN(pct_laid_off)			-- Result: 0.00
FROM layoffs_staging_2;

SELECT *
FROM layoffs_staging_2
WHERE total_laid_off >= 10000
ORDER BY total_laid_off DESC, company;		--    4 rows:  'Google' 12000;	'Meta' 11000;  'Amazon' 10000;  'Microsoft' 10000

SELECT *
FROM layoffs_staging_2
WHERE pct_laid_off >= 1
ORDER BY total_laid_off DESC;		--  116 rows;  all selected rows having pct_laid_off = 1.00

SELECT 
	company, 
	SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY company
ORDER BY 2 DESC, company;			-- 1628 rows

SELECT 
	company, 
	country,
	SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY company, country
ORDER BY 3 DESC, company;			-- 1651 rows


-- Identify the companies that are in multiple countries or locations,  HAVING sum_laid_off IS NOT NULL

-- Example of such company:
SELECT *
FROM layoffs_staging_2
WHERE company = 'Argo AI';

-- Query using Self JOIN
SELECT
	tbl_1.company,
	tbl_1.location,
	tbl_1.country,
	SUM(tbl_1.total_laid_off) AS sum_laid_off
FROM layoffs_staging_2 AS tbl_1
JOIN layoffs_staging_2 AS tbl_2
	ON   tbl_1.company  = tbl_2.company
	AND (tbl_1.country != tbl_2.country OR tbl_1.location != tbl_2.location)
GROUP BY tbl_1.company, tbl_1.country, tbl_1.location -- optional: ... WITH ROLLUP
HAVING sum_laid_off IS NOT NULL
ORDER BY tbl_1.company, tbl_1.country, tbl_1.location;			-- 54 rows	/ 62 rows without HAVING ...	/	127 rows with HAVING ... & WITH ROLLUP
-- For fun - incorrect data:  company 'Oda',  location 'Oslo',  country 'Sweden' vs 'Norway'  :)


--

SELECT 
	MIN(date_1),		-- Result: 2020-03-11
	MAX(date_1)			-- Result: 2023-03-06
FROM layoffs_staging_2;

SELECT 
	industry, 
	SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY industry
ORDER BY 2 DESC, industry;			-- 31 rows

SELECT 
	country, 
	SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY country
ORDER BY 2 DESC, country;			-- 51 rows		7 rows (countries) with NULL sum

SELECT 
	YEAR(date_1), 
	SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY YEAR(date_1)
ORDER BY 1 DESC;					-- 5 rows		1 row with NULL year

SELECT 
	stage, 
	SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY stage
ORDER BY 2 DESC;					-- 17 rows		1 row with NULL stage


SELECT 
	EXTRACT(YEAR_MONTH FROM date_1) AS yyyymm, 
	SUM(total_laid_off)
FROM layoffs_staging_2
WHERE EXTRACT(YEAR_MONTH FROM date_1) IS NOT NULL
GROUP BY yyyymm
ORDER BY yyyymm;					-- 36 rows

SELECT 
	company, 
	YEAR(date_1)        AS yyyy, 
	SUM(total_laid_off) AS sum_laid_off
FROM layoffs_staging_2
GROUP BY company, yyyy
HAVING sum_laid_off > 1000
ORDER BY sum_laid_off DESC;			-- 63 rows


SELECT 
	company, 
	YEAR(date_1)        AS yyyy, 
	SUM(total_laid_off) AS sum_laid_off
FROM layoffs_staging_2
GROUP BY company, yyyy
HAVING sum_laid_off > 700
ORDER BY yyyy, sum_laid_off DESC, company;		-- 97 rows


-- Companies with highest layoffs per years
-- Create the Dense rank (DESC order)...
-- Using 2 CTEs
WITH layoff_group_by_CTE (company, yyyy, sum_laid_off) AS
(
SELECT 
	company, 
	YEAR(date_1)        AS yyyy, 
	SUM(total_laid_off) AS sum_laid_off
FROM layoffs_staging_2
GROUP BY company, yyyy
HAVING sum_laid_off > 700
ORDER BY yyyy, sum_laid_off DESC, company
),
layoff_d_rank_CTE (company, yyyy, sum_laid_off, d_rank_yyyy) AS
(
SELECT 
	*,
	DENSE_RANK() OVER(PARTITION BY yyyy ORDER BY sum_laid_off DESC) AS d_rank_yyyy
FROM layoff_group_by_CTE
)
SELECT *
FROM layoff_d_rank_CTE
WHERE d_rank_yyyy <= 5;


-- Example:  'Amazon'
SELECT 
	company,
	date_1,
	total_laid_off
FROM layoffs_staging_2
WHERE company = 'Amazon';
-- 2 rows for 2022:		10000 + 150
-- 1 row  for 2023:		 8000



-- GROUP BY ... WITH ROLLUP
SELECT
	country,
	location,
	YEAR(date_1)        AS yyyy, 
	SUM(total_laid_off) AS sum_laid_off
FROM layoffs_staging_2
GROUP BY country, location, yyyy WITH ROLLUP
ORDER BY country, location, yyyy;

