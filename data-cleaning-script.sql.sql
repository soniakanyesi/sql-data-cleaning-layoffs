-- 1. Remove Duplicates
-- 2. Standardize the Data 
-- 3. Null values or Blank Values
-- 4. Remove any Blank or irrelevant columns 

SELECT * 
FROM layoffs;

CREATE TABLE layoffs_staging3
LIKE layoffs;

 INSERT layoffs_staging3
 SELECT *
 FROM layoffs;
 SELECT *
 FROM layoffs_staging3
 ;
 
 SELECT *,
 ROW_NUMBER () OVER (
 PARTITION BY company, industry, total_laid_off, percentage_laid_off, 'date') 
 AS row_num
 FROM layoffs_staging;
 
 WITH duplicate_cte AS  
 (
 SELECT *,
 ROW_NUMBER () OVER (
 PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage,
 country, funds_raised_millions
 ) AS row_num
 FROM layoffs_staging
 )
SELECT *
FROM duplicate_cte
WHERE row_num >1
 ;
 SELECT *
 FROM layoffs_staging 
 WHERE company = 'Casper';

WITH duplicate_cte AS  
 (
 SELECT *,
 ROW_NUMBER () OVER (
 PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage,
 country, funds_raised_millions
 ) AS row_num
 FROM layoffs_staging3
 )
DELETE 
FROM duplicate_cte 
WHERE row_num > 1
;
CREATE TABLE `layoffs_staging4` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
`row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging4
;
INSERT INTO layoffs_staging4
SELECT *,
 ROW_NUMBER () OVER (
 PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage,
 country, funds_raised_millions
 ) AS row_num
 FROM layoffs_staging3;
 
DELETE 
 FROM layoffs_staging4
WHERE row_num > 1;

SELECT *
FROM layoffs_staging4
WHERE row_num > 1;

-- Standardizing Data 
SELECT company, TRIM(company)
FROM layoffs_staging4
;
UPDATE layoffs_staging4
SET company = TRIM(company)
;
SELECT *
FROM layoffs_staging4
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging4
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging4
;
UPDATE layoffs_staging4
SET country = 'United States'
WHERE country LIKE 'United States%';

SELECT DISTINCT country 
FROM layoffs_staging4
WHERE country LIKE 'United Stat%';

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging4;

UPDATE layoffs_staging4
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y')
;

ALTER TABLE layoffs_staging4
MODIFY COLUMN `date` DATE;

SELECT *
FROM layoffs_staging4
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging4
WHERE industry IS NULL
OR industry = '';

SELECT *
FROM layoffs_staging4
WHERE company like 'Airbnb';

UPDATE layoffs_staging4
SET industry  = NULL
WHERE industry = '';

select *
FROM layoffs_staging4
WHERE percentage_laid_off IS NULL
AND total_laid_off IS NULL
; 
SELECT t1.industry, t2.industry
FROM layoffs_staging4 t1
	JOIN layoffs_staging4 t2
	ON t1.company = t2.company
	AND t1.location = t2.location 
WHERE  t1.industry IS NULL
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging4 t1
JOIN layoffs_staging4 t2
	ON t1.company = t2.company
	AND t1.location = t2.location
SET  t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL
;
SELECT * 
FROM layoffs_staging4
WHERE company LIKE 'Juul'
;
-- Removing Unnecessary Columns and Rows 

SELECT *
FROM layoffs_staging4
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
;
DELETE 
FROM layoffs_staging4
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_staging4
DROP COLUMN row_num 
;
SELECT *
FROM layoffs_staging4;
