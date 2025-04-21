SELECT *
FROM layoffs;

-- Create Staging Table

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT *
FROM layoffs;

SELECT * 
FROM layoffs_staging;


-- Check for Duplicates

WITH duplicate_cte AS
(
SELECT *,
row_number() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- Remove Duplicates

-- Create New Table "layoffs_staging2" with row_num column
-- Delete rows where row_num > 2

CREATE TABLE `layoffs_staging2` (
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
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
row_number() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
FROM layoffs_staging;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;


-- Standardizing the Data

SELECT DISTINCT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

-- Multiple industrys with different spellings for Crypto Currency
-- Standardize them all as 'Crypto'

SELECT DISTINCT industry
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT country
FROM layoffs_staging2
WHERE country LIKE 'United States%'
order by 1;

UPDATE layoffs_staging2
SET country = 'United States'
WHERE country LIKE 'United States%';

-- Format Date

SELECT `date`,
str_to_date(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = str_to_date(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- Address Null Values

-- Fix companies that have Null Values for some but not all industry

SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

SELECT t1.industry, t2.industry
FROM layoffs_staging2 as t1
JOIN layoffs_staging2 as t2
	ON t1.company = t2.company
WHERE 
	t1.industry IS NULL
    AND t2.industry is NOT NULL;

UPDATE layoffs_staging2 as t1
JOIN layoffs_staging2 as t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE 
	t1.industry IS NULL
    AND t2.industry is NOT NULL;
    
SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

-- Remove rows with no layoff information

SELECT *
FROM layoffs_staging2
WHERE 
	total_laid_off is NULL
    AND percentage_laid_off IS NULL;

DELETE 
FROM layoffs_staging2
WHERE 
	total_laid_off is NULL
    AND percentage_laid_off IS NULL;
    
-- Remove row_num column

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;






