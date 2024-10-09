-- MySQL Project - Part 1 - Data Cleaning
-- **************************************

-- Links
-- Dataset:        https://www.kaggle.com/datasets/swaptr/layoffs-2022
-- Guiding video:  https://www.youtube.com/watch?v=4UltKCnnnTA


-- Approach
-- 0. Copy the Raw data / table into the Staging table
-- 1. Remove duplicate rows
-- 2. Standardize the Data and Fix errors
-- 3. Look at the Null values / Blank values
-- 4. Remove any Rows and Columns that are not necessary



-- 0. Copy the Raw data / table into the Staging table
-- ***************************************************

TABLE layoffs_raw;		-- 2361 rows

-- After import of the dataset into MySQL, the column 'percentage_laid_off' is Datatype TEXT, instead of DECIMAL
SELECT *
FROM layoffs_raw
WHERE LENGTH(percentage_laid_off) > 4;		-- Result: 5 records with more than 2 decimal places in the column 'percentage_laid_off' (Datatype TEXT)


CREATE TABLE layoffs_staging_1
LIKE layoffs_raw;

TABLE layoffs_staging_1;

ALTER TABLE layoffs_staging_1
ADD COLUMN row_n INT NOT NULL AUTO_INCREMENT FIRST,
ADD PRIMARY KEY (row_n),
CHANGE COLUMN percentage_laid_off pct_laid_off DECIMAL(8, 2) NULL DEFAULT NULL,
CHANGE COLUMN `date` date_txt TEXT NULL DEFAULT NULL,
CHANGE COLUMN funds_raised_millions funds_r_mio INT NULL DEFAULT NULL;


INSERT INTO layoffs_staging_1 (company, location, industry, total_laid_off, pct_laid_off, date_txt, stage, country, funds_r_mio)
SELECT *
FROM layoffs_raw;

-- Result:
-- 2361 row(s) affected, 5 warning(s): 
-- 1265 Data truncated for column 'pct_laid_off' at row 522 
-- 1265 Data truncated for column 'pct_laid_off' at row 565 
-- 1265 Data truncated for column 'pct_laid_off' at row 946 
-- 1265 Data truncated for column 'pct_laid_off' at row 1755 
-- 1265 Data truncated for column 'pct_laid_off' at row 1763 
-- Records: 2361  Duplicates: 0  Warnings: 5

SELECT *
FROM layoffs_staging_1
WHERE row_n IN (522, 565, 946, 1755, 1763);		-- To check rounding of 'pct_laid_off' with more than 2 decimal places after import

SELECT MIN(pct_laid_off), MAX(pct_laid_off)
FROM layoffs_staging_1;							-- Result:  MIN: 0.00,  MAX: 1.00



-- 1. Remove duplicate rows
-- ************************

SELECT 
	*,
	ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, pct_laid_off, date_txt, stage, country, funds_r_mio) 
		AS row_n_over
FROM layoffs_staging_1;


-- Using the previous query in the CTE
WITH duplic_rows_CTE AS
(
SELECT 
	*,
	ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, pct_laid_off, date_txt, stage, country, funds_r_mio) 
		AS row_n_over
FROM layoffs_staging_1
)
SELECT *
FROM duplic_rows_CTE
WHERE row_n_over > 1;		-- Result:  5 rows  (row_n:  1690, 1493, 2255, 626, 2358) (column company:  'Casper', 'Cazoo', 'Hibob', 'Wildlife Studios', 'Yahoo')

-- Check the duplicate rows
SELECT *
FROM layoffs_staging_1
WHERE company IN ('Casper', 'Cazoo', 'Hibob', 'Wildlife Studios', 'Yahoo')
ORDER BY company, total_laid_off;


CREATE TABLE layoffs_staging_2
LIKE layoffs_staging_1;

TABLE layoffs_staging_2;

ALTER TABLE layoffs_staging_2
CHANGE COLUMN row_n row_n INT NOT NULL,		-- to cancel the AUTO_INCREMENT
ADD    COLUMN row_n_over  INT NULL AFTER funds_r_mio;

INSERT INTO layoffs_staging_2
SELECT 
	*,
	ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, pct_laid_off, date_txt, stage, country, funds_r_mio)
FROM layoffs_staging_1;		-- 2361 rows affected  Records: 2361  Duplicates: 0  Warnings: 0

SELECT *
FROM layoffs_staging_2
WHERE row_n_over > 1
ORDER BY company;

-- Recommended approach:
-- 1. SELECT ... WHERE ...
-- 2. Check the result ...
-- 3. DELETE ... WHERE ... [the same conditions] - i.e. Delete selected rows if the result is OK
DELETE
FROM layoffs_staging_2
WHERE row_n_over > 1;		-- 5 row(s) affected




-- 2. Standardize the Data and Fix errors
-- **************************************

-- Column: company

SELECT *
FROM layoffs_staging_2
ORDER BY company;

SELECT *
FROM layoffs_staging_2
WHERE company LIKE ' %';		-- 2 rows returned

UPDATE layoffs_staging_2
SET company = TRIM(company);	-- 11 rows affected  Rows matched: 2356  Changed: 11  Warnings: 0


-- Column: industry

SELECT DISTINCT industry
FROM layoffs_staging_2
ORDER BY industry;

SELECT *
FROM layoffs_staging_2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging_2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';	-- 3 rows affected  Rows matched: 102  Changed: 3  Warnings: 0



-- Column: location

SELECT DISTINCT location
FROM layoffs_staging_2
ORDER BY location;
-- Issues found:
--   DĂĽsseldorf	Dusseldorf		row_n:  833
--   FlorianĂłpolis					row_n: 1283
--   MalmĂ¶			Malmo			row_n:  710

SELECT *
FROM layoffs_staging_2
WHERE LOCATE('Ă', location) > 0;	-- 3 rows returned


SELECT *
FROM layoffs_staging_2
WHERE location LIKE 'D%sseldorf';

UPDATE layoffs_staging_2
SET location = 'Dusseldorf'
WHERE location LIKE 'D%sseldorf';		-- 1 row affected  Rows matched: 2  Changed: 1  Warnings: 0


SELECT *
FROM layoffs_staging_2
WHERE location LIKE 'Florian%polis';

UPDATE layoffs_staging_2
SET location = 'Florianopolis'
WHERE location LIKE 'Florian%polis';	-- 1 row affected  Rows matched: 1  Changed: 1  Warnings: 0

SELECT *
FROM layoffs_staging_2
WHERE location LIKE 'Malm%';

UPDATE layoffs_staging_2
SET location = 'Malmo'
WHERE location LIKE 'Malm%';			-- 1 row affected  Rows matched: 2  Changed: 1  Warnings: 0


-- Column: country

SELECT DISTINCT country
FROM layoffs_staging_2
ORDER BY country;

SELECT *
FROM layoffs_staging_2
WHERE country LIKE '%.';		-- 4 rows returned		'United States.'

UPDATE layoffs_staging_2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE '%.';		-- 4 rows affected  Rows matched: 4  Changed: 4  Warnings: 0


-- Column: date_txt --> use the STR_TO_DATE() function

SELECT *, STR_TO_DATE(date_txt, '%m/%d/%Y')
FROM layoffs_staging_2;

UPDATE layoffs_staging_2
SET date_txt = STR_TO_DATE(date_txt, '%m/%d/%Y');	-- 2355 rows affected  Rows matched: 2356  Changed: 2355  Warnings: 0

TABLE layoffs_staging_2;

ALTER TABLE layoffs_staging_2
CHANGE COLUMN date_txt date_1 DATE NULL DEFAULT NULL;	-- 2356 rows affected  Records: 2356  Duplicates: 0  Warnings: 0

SELECT *
FROM layoffs_staging_2
WHERE date_1 IS NULL;		-- 1 row		row_n: 2357		company: 'Blackbaud'


-- Additional check of the other columns:  company, industry, country

SELECT *
FROM layoffs_staging_2
WHERE 
	LOCATE('Ă', company)  > 0 OR 
	LOCATE('Ă', industry) > 0 OR 
	LOCATE('Ă', country)  > 0;		-- 1 row		row_n: 606		company: 'UalĂˇ'

SELECT *
FROM layoffs_staging_2
WHERE company LIKE 'Ual%';			-- 1 row

UPDATE layoffs_staging_2
SET company = 'Uala'
WHERE company LIKE 'Ual%';			-- 1 rows affected  Rows matched: 1  Changed: 1  Warnings: 0



-- 3. Look at the Null values / Blank values
-- *****************************************

SELECT *
FROM layoffs_staging_2
WHERE industry IS NULL
OR    industry = '';			-- Result:  Column industry:  1 row with NULL value,  3 rows with Blank values

SELECT *
FROM layoffs_staging_2
WHERE company = 'Airbnb';		-- Data from the other row(s):  e.g. value for the Column industry for the company 'Airbnb' can be changed to 'Travel'

UPDATE layoffs_staging_2		-- Replace Blank values with NULL
SET industry = NULL
WHERE industry = '';			-- 3 rows affected  Rows matched: 3  Changed: 3  Warnings: 0

SELECT *
FROM layoffs_staging_2
WHERE industry IS NULL;			-- Result:  4 rows,  company: "Airbnb", "Bally's Interactive", "Carvana", "Juul"

SELECT *
FROM layoffs_staging_2
WHERE company IN ("Airbnb", "Bally's Interactive", "Carvana", "Juul")
ORDER BY company;				-- 8 rows

-- Self join...  SELECT
SELECT *
FROM layoffs_staging_2 AS tb1
JOIN layoffs_staging_2 AS tb2
	ON  tb1.company  = tb2.company
	AND tb1.location = tb2.location
WHERE tb1.industry IS NULL
AND   tb2.industry IS NOT NULL;		-- 4 rows

-- Self join...  UPDATE
UPDATE layoffs_staging_2 AS tb1
JOIN   layoffs_staging_2 AS tb2
	ON  tb1.company  = tb2.company
	AND tb1.location = tb2.location
SET tb1.industry = tb2.industry
WHERE tb1.industry IS NULL
AND   tb2.industry IS NOT NULL;			-- 3 rows affected  Rows matched: 3  Changed: 3  Warnings: 0



-- 4. Remove any Rows and Columns that are not necessary
-- *****************************************************

SELECT *
FROM layoffs_staging_2
WHERE total_laid_off IS NULL
AND   pct_laid_off   IS NULL;		-- 361 rows

DELETE
FROM layoffs_staging_2
WHERE total_laid_off IS NULL
AND   pct_laid_off   IS NULL;		-- 361 rows affected


ALTER TABLE layoffs_staging_2
DROP COLUMN row_n_over;

-- Final table - check
TABLE layoffs_staging_2;			-- 1995 rows



--

SELECT LAST_INSERT_ID();


-- Help ...

HELP 'ALTER TABLE';
HELP 'TRIM';
HELP 'STR_TO_DATE';
HELP 'DATE_FORMAT';
HELP 'AUTO_INCREMENT';

