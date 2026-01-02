-- DATA CLEANING
-- 1. REMOVE DUPLICATES
-- 2. STANDARDIZING DATA
-- 3. CHECKING FOR NULL VALUES OR BLANK VALUES
-- 4. REMOVE COLUMNS OR ROWS

SELECT *
FROM layoffs;

CREATE TABLE layoffs_worksheet
LIKE layoffs;

SELECT *
FROM layoffs_worksheet;

INSERT layoffs_worksheet
SELECT *
FROM layoffs;


-- REMOVING DUPLICATES
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY
company, location,
industry, total_laid_off,
`date`
) AS row_num
FROM layoffs_worksheet;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY
company, location,
industry, total_laid_off,
percentage_laid_off,`date`,
stage, country,
funds_raised_millions
) AS row_num
FROM layoffs_worksheet
)

SELECT *
FROM duplicate_cte
WHERE row_num > 1;


SELECT *
FROM layoffs_worksheet
WHERE company = 'Casper';


CREATE TABLE `layoffs_worksheet2` (
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


INSERT INTO layoffs_worksheet2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY
company, location,
industry, total_laid_off,
percentage_laid_off,`date`,
stage, country,
funds_raised_millions
) AS row_num
FROM layoffs_worksheet;

DELETE
FROM layoffs_worksheet2
WHERE row_num > 1;

SELECT *
FROM layoffs_worksheet2;

-- STANDARDIZING DATA
SELECT company, TRIM(company)
FROM layoffs_worksheet2;

UPDATE layoffs_worksheet2
SET company = TRIM(company);

SELECT DISTINCT(industry)
FROM layoffs_worksheet2
ORDER BY 1;

SELECT *
FROM layoffs_worksheet2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_worksheet2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT(location)
FROM layoffs_worksheet2;

SELECT DISTINCT(country), TRIM(TRAILING '.' FROM country)
FROM layoffs_worksheet2
ORDER BY 1;

UPDATE layoffs_worksheet2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

SELECT `date`
FROM layoffs_worksheet2
WHERE `date` IS NULL;

SELECT `date`, STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_worksheet2;

UPDATE layoffs_worksheet2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_worksheet2
MODIFY COLUMN `date` DATE;

SELECT *
FROM layoffs_worksheet2;



-- WORKING WITH NULLS AND BLANKS 
SELECT *
FROM layoffs_worksheet2
WHERE industry IS NULL
OR industry = '';

SELECT *
FROM layoffs_worksheet2
WHERE company = 'Airbnb';

SELECT *
FROM layoffs_worksheet2
WHERE company = 'Carvana';

SELECT *
FROM layoffs_worksheet2
WHERE company = 'Juul';

-- Populating blanks
UPDATE layoffs_worksheet2
SET industry = NULL
WHERE industry = '';

SELECT t1.industry, t2.industry
FROM layoffs_worksheet2 t1
JOIN layoffs_worksheet2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL )
AND t2.industry IS NOT NULL;


UPDATE layoffs_worksheet2 t1
JOIN layoffs_worksheet2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL )
AND t2.industry IS NOT NULL;

-- REMOVING ROW AND COLUMNS
SELECT *
FROM layoffs_worksheet2
WHERE total_laid_off IS NULL
AND percentage_laid_off is null;

DELETE
FROM layoffs_worksheet2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_worksheet2;

ALTER TABLE layoffs_worksheet2
DROP COLUMN row_num;























