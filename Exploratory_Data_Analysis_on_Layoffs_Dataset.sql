-- EXPLORATORY DATA ANALYSIS

SELECT *
FROM layoffs_worksheet2;

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_worksheet2;


-- CHECKING THE DATE RANGE OF THE LAYOFF DATASET
-- The dataset starts from 2020 to 2023
SELECT MAX(`date`), MIN(`date`)
FROM layoffs_worksheet2;

-- FUNDS RAISED PER COMPANIES THAT WENT UNDER/COLLAPSED
-- Britishvolt raised $2.4 billion before it went under. Which is the highest amount raised from 2020 to 2023. 
SELECT *
FROM layoffs_worksheet2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- TOTAL LAID_OFF PER COMPANY
-- Amazon laid off 18,150 people representing the largest number of people that were laid_off from 2020 to 2023.
SELECT company, SUM(total_laid_off)
FROM layoffs_worksheet2
GROUP BY company
ORDER BY 2 DESC;

-- TOTAL LAID_OFF PER INDUSTRY
-- A total of 45182 people were laid_off from the Consumer industry from 2020 to 2023. 
-- That's the highest laid_off per industry followed by the Retail industry
SELECT industry, SUM(total_laid_off)
FROM layoffs_worksheet2
GROUP BY industry
ORDER BY 2 DESC;

-- TOTAL LAID_OFF PER COUNTRY
SELECT country, SUM(total_laid_off)
FROM layoffs_worksheet2
GROUP BY country
ORDER BY 2 DESC;
-- The United States laid off a total of 256,559 people representing the largest number of people that were laid_off from 2020 to 2023.
-- United States, India, Netherlands, Sweden and Brazil are the top 5 countries with the highest laid_off from 2020 to 2023


-- TOTAL LAID_OFF PER YEAR(2020-2023)
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_worksheet2
GROUP BY YEAR(`date`)
ORDER BY 2 DESC;
-- A total of 160,661 people were laid_off in 2022, followed by 2023 with a total of 125,677 people getting laid_off.
-- 80,998 people were laid_off in 2020
-- In 2021, 15,823 people were laid_off


-- TOTAL LAID_OFF PER THE STAGE OF THE COMPANIES (2020-2023)
SELECT stage, SUM(total_laid_off)
FROM layoffs_worksheet2
GROUP BY stage
ORDER BY 2 DESC;
-- Post-IPO companies laid off a total of 204,132 people as the highest laid_off
-- The third largest laid_off was done by companies that were Acquired. Laying off a total of 27,576 people.
-- Subsidiary companies had the lowest laid_off of 1,094 people


-- TOTAL NUMBER OF COMPANIES THAT WENT UNDER PER COUNTRY (2020-2023)
SELECT country, COUNT(percentage_laid_off)
FROM layoffs_worksheet2
WHERE percentage_laid_off = 1
GROUP BY country
ORDER BY 2 DESC;
-- There were a total of 73 companies in the United States that went under.


-- ROLLING TOTAL
-- FINDING OUT HOW MANY PEOPLE WERE LAID_OFF EACH MONTH STARTING FROM 2020-03
SELECT SUBSTRING(`date`, 1, 7) `MONTH`,
SUM(total_laid_off)
FROM layoffs_worksheet2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1;

WITH Rolling_Total AS 
(
	SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`,
	SUM(total_laid_off) AS total_laid
	FROM layoffs_worksheet2
	WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
	GROUP BY `MONTH`
	ORDER BY 1
)
SELECT 
	`MONTH`, 
	total_laid, 
	SUM(total_laid) OVER(ORDER BY `MONTH`) as rolling_total
FROM Rolling_Total;


-- RANKING COMPANIES BASED ON HOW MANY PEOPLE THEY LAID_OFF PER YEAR
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_worksheet2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

WITH company_years (company, years, total_laid) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_worksheet2
GROUP BY company, YEAR(`date`)
), company_years_rank AS
(
SELECT *,
DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid DESC) AS ranking
FROM company_years
WHERE years IS NOT NULL
)
SELECT *
FROM company_years_rank
WHERE ranking <= 5;
-- In 2020, Uber laid _off 7,525 people
-- In 2021, Bytedance laid_off 3,600 people
-- In 2022, Meta laid_off 11,000 people
-- In 2023, Google laid_off 12,000 people
