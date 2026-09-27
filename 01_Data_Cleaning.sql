-- SQL Project - Data Cleaning
-- Global Layoffs Dataset
USE world_layoffs;

-- 1. CHECK THE RAW DATA
SELECT *
FROM layoffs;


-- 2. CREATE A STAGING TABLE
-- We keep the original table unchanged and perform
-- our cleaning on a copy.
CREATE TABLE layoffs_staging LIKE layoffs;

INSERT INTO layoffs_staging
SELECT *
FROM layoffs;


-- 3. CHECK FOR DUPLICATES
SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY
            company,
            location,
            total_laid_off,
            `date`,
            percentage_laid_off,
            industry,
            source,
            stage,
            funds_raised,
            country,
            date_added
        ORDER BY company
    ) AS row_num
FROM layoffs_staging;


-- 4. CREATE A SECOND STAGING TABLE
--    TO IDENTIFY DUPLICATES
CREATE TABLE layoffs_staging2 AS
SELECT
    company,
    location,
    total_laid_off,
    `date`,
    percentage_laid_off,
    industry,
    source,
    stage,
    funds_raised,
    country,
    date_added,
    ROW_NUMBER() OVER (
        PARTITION BY
            company,
            location,
            total_laid_off,
            `date`,
            percentage_laid_off,
            industry,
            source,
            stage,
            funds_raised,
            country,
            date_added
        ORDER BY company
    ) AS row_num
FROM layoffs_staging;

-- Check which rows have been identified as duplicates.
SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

-- Remove duplicate rows.
DELETE FROM layoffs_staging2
WHERE row_num > 1;


-- 5. STANDARDIZE TEXT VALUES
-- Remove unnecessary spaces from text columns.
UPDATE layoffs_staging2
SET
    company = TRIM(company),
    location = TRIM(location),
    industry = TRIM(industry),
    source = TRIM(source),
    stage = TRIM(stage),
    country = TRIM(country);

-- Convert blank industry values into NULL.
UPDATE layoffs_staging2
SET industry = NULL
WHERE TRIM(industry) = '';

-- Convert blank location values into NULL.
UPDATE layoffs_staging2
SET location = NULL
WHERE TRIM(location) = '';

-- Convert blank stage values into NULL.
UPDATE layoffs_staging2
SET stage = NULL
WHERE TRIM(stage) = '';

-- Convert blank country values into NULL.
UPDATE layoffs_staging2
SET country = NULL
WHERE TRIM(country) = '';

-- Convert blank source values into NULL.
UPDATE layoffs_staging2
SET source = NULL
WHERE TRIM(source) = '';

-- Check the standardized values.
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY industry;

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY country;

SELECT DISTINCT stage
FROM layoffs_staging2
ORDER BY stage;


-- 6. STANDARDIZE DATE VALUES
-- Convert the text date into a proper MySQL DATE.
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Convert date_added as well.
UPDATE layoffs_staging2
SET date_added = STR_TO_DATE(date_added, '%m/%d/%Y');

-- Change the column data types to DATE.
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

ALTER TABLE layoffs_staging2
MODIFY COLUMN date_added DATE;

-- Check the date range.
SELECT
    MIN(`date`) AS earliest_layoff_date,
    MAX(`date`) AS latest_layoff_date
FROM layoffs_staging2;


-- 7. CHECK MISSING VALUES
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
   OR percentage_laid_off IS NULL
   OR funds_raised IS NULL;

-- Find rows where BOTH main layoff measures are missing.
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

-- These rows cannot contribute to most of our analysis,
-- so remove them.
DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;


-- 8. CHECK MISSING CATEGORICAL VALUES
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL;

SELECT *
FROM layoffs_staging2
WHERE country IS NULL;

SELECT *
FROM layoffs_staging2
WHERE stage IS NULL;

-- We leave these values as NULL because there is no
-- reliable information available to fill them.


-- 9. FINAL CLEANUP
-- The row number was only needed for duplicate removal.
-- It is no longer part of our cleaned dataset.
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;


-- 10. FINAL CHECK
SELECT *
FROM layoffs_staging2;

-- Check how many rows remain after cleaning.
SELECT COUNT(*) AS cleaned_row_count
FROM layoffs_staging2;