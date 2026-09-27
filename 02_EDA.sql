-- SQL Project - Exploratory Data Analysis
-- Global Layoffs Dataset
-- Uses the cleaned table created in the Data Cleaning project
USE world_layoffs;

-- 1. Get a first look at the cleaned data
SELECT *
FROM layoffs_staging2;


-- 2. Basic EDA
-- What is the largest number of employees laid off
-- in a single event?
SELECT MAX(total_laid_off) AS largest_single_layoff
FROM layoffs_staging2;

-- What is the highest percentage of employees laid off?
SELECT MAX(percentage_laid_off) AS highest_percentage_laid_off
FROM layoffs_staging2;

-- What is the lowest percentage of employees laid off?
SELECT MIN(percentage_laid_off) AS lowest_percentage_laid_off
FROM layoffs_staging2
WHERE percentage_laid_off IS NOT NULL;

-- Companies where 100% of employees were laid off.
SELECT
    company,
    location,
    industry,
    total_laid_off,
    percentage_laid_off,
    funds_raised,
    `date`
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised DESC;


-- 3. Companies with the largest layoffs
-- Largest individual layoff events.
SELECT
    company,
    `date`,
    total_laid_off
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
ORDER BY total_laid_off DESC
LIMIT 10;

-- Companies with the highest total number of layoffs.
SELECT
    company,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY company
ORDER BY total_layoffs DESC
LIMIT 10;


-- 4. Layoffs by location
SELECT
    location,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY location
ORDER BY total_layoffs DESC
LIMIT 10;


-- 5. Layoffs by country
SELECT
    country,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY country
ORDER BY total_layoffs DESC
LIMIT 10;


-- 6. Layoffs by year
SELECT
    YEAR(`date`) AS year,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
WHERE `date` IS NOT NULL
GROUP BY YEAR(`date`)
ORDER BY year;


-- 7. Layoffs by industry
SELECT
    industry,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY industry
ORDER BY total_layoffs DESC;

-- 8. Layoffs by company stage
SELECT
    stage,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY stage
ORDER BY total_layoffs DESC;


-- 9. Companies with the most layoffs per year
WITH company_year AS
(
    SELECT
        company,
        YEAR(`date`) AS year,
        SUM(total_laid_off) AS total_layoffs
    FROM layoffs_staging2
    WHERE `date` IS NOT NULL
    GROUP BY company, YEAR(`date`)
),

company_year_ranked AS
(
    SELECT
        company,
        year,
        total_layoffs,
        DENSE_RANK() OVER (
            PARTITION BY year
            ORDER BY total_layoffs DESC
        ) AS ranking
    FROM company_year
)

SELECT
    company,
    year,
    total_layoffs,
    ranking
FROM company_year_ranked
WHERE ranking <= 3
ORDER BY year, total_layoffs DESC;


-- 10. Monthly layoffs
SELECT
    DATE_FORMAT(`date`, '%Y-%m') AS month,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
WHERE `date` IS NOT NULL
GROUP BY DATE_FORMAT(`date`, '%Y-%m')
ORDER BY month;


-- 11. Rolling total of layoffs
WITH monthly_layoffs AS
(
    SELECT
        DATE_FORMAT(`date`, '%Y-%m') AS month,
        SUM(total_laid_off) AS total_layoffs
    FROM layoffs_staging2
    WHERE `date` IS NOT NULL
    GROUP BY DATE_FORMAT(`date`, '%Y-%m')
)

SELECT
    month,
    total_layoffs,
    SUM(total_layoffs) OVER (
        ORDER BY month
    ) AS rolling_total_layoffs
FROM monthly_layoffs
ORDER BY month;


-- 12. Total number of layoffs
SELECT
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2;


-- 13. Number of unique companies
SELECT
    COUNT(DISTINCT company) AS unique_companies
FROM layoffs_staging2;


-- 14. Number of unique industries
SELECT
    COUNT(DISTINCT industry) AS unique_industries
FROM layoffs_staging2;


-- 15. Records with the highest layoff percentage
SELECT
    company,
    industry,
    country,
    percentage_laid_off,
    total_laid_off,
    `date`
FROM layoffs_staging2
WHERE percentage_laid_off IS NOT NULL
ORDER BY percentage_laid_off DESC,
         total_laid_off DESC
LIMIT 10;

-- new ones
WITH c as (
	SELECT company,industry,SUM(total_laid_off) AS total_off
	FROM layoffs_staging2
	GROUP BY company,industry
),
ranked as(
	SELECT *, DENSE_RANK() OVER(PARTITION BY industry ORDER BY total_off) AS ranking
	FROM c
)
SELECT *
FROM ranked 
WHERE ranking <=3;

WITH layoff_per_year AS
(
	SELECT YEAR(date) as years,SUM(total_laid_off) AS total_lay_off
    FROM layoffs_staging2 
    GROUP BY YEAR(date)
)
SELECT *,
LAG(total_lay_off) OVER(ORDER BY years) as last_year,
total_lay_off - LAG(total_lay_off) OVER(ORDER BY years ASC) as difference_in_years    
FROM layoff_per_year;

WITH layoffs AS (
	SELECT company,
    SUM(total_laid_off) layoff_per_company
    FROM layoffs_staging2
    GROUP BY company
),
total_layoffs AS (
	SELECT SUM(total_laid_off) AS total_layoff
    FROM layoffs_staging2
),
layoff_percentage AS (
	SELECT *,
    (layoff_per_company / total_layoff)*100 AS layoff_per,
    DENSE_RANK() OVER(ORDER BY layoff_per_company DESC) AS comp_rank
    FROM layoffs,total_layoffs
)
SELECT *
FROM layoff_percentage
WHERE comp_rank <=10;

WITH cte AS (
    SELECT
        company,
        funds_raised,
        total_laid_off,
        CASE
            WHEN funds_raised <= 50 THEN 'Low'
            WHEN funds_raised <= 200 THEN 'Medium'
            ELSE 'High'
        END AS funding_band
    FROM layoffs_staging2
)
SELECT
    funding_band,
    AVG(total_laid_off) AS avg_layoffs
FROM cte
GROUP BY funding_band;

SELECT company,SUM(total_laid_off),funds_raised
FROM layoffs_staging2
WHERE percentage_laid_off = 1
GROUP BY company,funds_raised
ORDER BY SUM(total_laid_off) DESC;

SELECT
    industry,
    SUM(total_laid_off) AS total_layoffs,
    AVG(total_laid_off) AS avg_layoff_event,
    COUNT(*) AS number_of_events
FROM layoffs_staging2
GROUP BY industry
ORDER BY total_layoffs DESC;

SELECT company,SUM(total_laid_off) AS total_lay_off,
COUNT(DISTINCT YEAR(date)) AS number_of_years
FROM layoffs_staging2
GROUP BY company
HAVING COUNT(DISTINCT YEAR(date)) > 1
ORDER BY SUM(total_laid_off) DESC;

WITH layoffs AS(
	SELECT industry,location,SUM(total_laid_off) AS total_layoffs
    FROM layoffs_staging2
    GROUP BY industry,location
),
layoff_rank AS (
	SELECT *,
    DENSE_RANK() OVER(ORDER BY total_layoffs DESC) AS ranking
    FROM layoffs
)
SELECT *
FROM layoff_rank 
WHERE ranking <=10;


-- 16. Top 3 companies by layoffs within each industry
WITH c AS (
    SELECT company, industry, SUM(total_laid_off) AS total_off
    FROM layoffs_staging2
    GROUP BY company, industry
),
ranked AS (
    SELECT *,
           DENSE_RANK() OVER(PARTITION BY industry ORDER BY total_off DESC) AS ranking
    FROM c
)
SELECT *
FROM ranked
WHERE ranking <= 3;


-- 17. Year-over-year change in layoffs
WITH layoff_per_year AS (
    SELECT YEAR(`date`) AS year,
           SUM(total_laid_off) AS total_lay_off
    FROM layoffs_staging2
    GROUP BY YEAR(`date`)
)
SELECT *,
       LAG(total_lay_off) OVER(ORDER BY year) AS previous_year,
       total_lay_off - LAG(total_lay_off) OVER(ORDER BY year) AS difference
FROM layoff_per_year;


-- 18. Layoff concentration among top 10 companies
WITH layoffs AS (
    SELECT company,
           SUM(total_laid_off) AS layoff_per_company
    FROM layoffs_staging2
    GROUP BY company
),
ranked AS (
    SELECT *,
           layoff_per_company / SUM(layoff_per_company) OVER() * 100 AS layoff_per,
           DENSE_RANK() OVER(ORDER BY layoff_per_company DESC) AS comp_rank
    FROM layoffs
)
SELECT *
FROM ranked
WHERE comp_rank <= 10;


-- 19. Average layoff size by industry
SELECT industry,
       SUM(total_laid_off) AS total_layoffs,
       AVG(total_laid_off) AS avg_layoff_event,
       COUNT(total_laid_off) AS number_of_events
FROM layoffs_staging2
GROUP BY industry
ORDER BY total_layoffs DESC;


-- 20. Companies where 100% of employees were laid off
SELECT company,
       funds_raised,
       SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
WHERE percentage_laid_off = 1
GROUP BY company, funds_raised
ORDER BY total_layoffs DESC;


-- 21. Average layoffs by funding band
WITH cte AS (
    SELECT *,
           CASE
               WHEN funds_raised < 50 THEN 'Low'
               WHEN funds_raised <= 200 THEN 'Medium'
               ELSE 'High'
           END AS funding_band
    FROM layoffs_staging2
)
SELECT funding_band,
       AVG(total_laid_off) AS avg_layoffs
FROM cte
GROUP BY funding_band;


-- 22. Companies with layoffs across multiple years
SELECT company,
       SUM(total_laid_off) AS total_lay_off,
       COUNT(DISTINCT YEAR(`date`)) AS number_of_years
FROM layoffs_staging2
GROUP BY company
HAVING COUNT(DISTINCT YEAR(`date`)) > 1
ORDER BY total_lay_off DESC;


-- 23. Top 10 location + industry combinations
WITH layoffs AS (
    SELECT industry, location,
           SUM(total_laid_off) AS total_layoffs
    FROM layoffs_staging2
    GROUP BY industry, location
),
ranked AS (
    SELECT *,
           DENSE_RANK() OVER(ORDER BY total_layoffs DESC) AS ranking
    FROM layoffs
)
SELECT *
FROM ranked
WHERE ranking <= 10;