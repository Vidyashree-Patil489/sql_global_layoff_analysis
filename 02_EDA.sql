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