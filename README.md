# World Wide Layoffs Cleaning Project

## Data Cleaning Process

The layoff dataset was cleaned and structured using SQL to ensure accuracy and consistency. Below are the key steps performed, with examples taken directly from the `layoff_cleaning.sql` script.

---

### 1. Remove Duplicate Records

To ensure unique records, all distinct rows where counted and identified using a `ROW_NUMBER()` function. 
If a row was a duplicate, it would be counted a second time and then deleted if they had `row_num > 1`.

```sql
INSERT INTO layoffs_staging2
SELECT *,
row_number() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
FROM layoffs_staging;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;
```

---

### 2. Standardize Values

Trimmed and normalized inconsistent or misspelled values in the `location` column.

```sql
SELECT DISTINCT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);
```
Find and update instances where the same data (e.g., company names, countries, or industries) was entered in multiple inconsistent formats

```sql
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
```

Standardize the date to make future analysis easier.

```sql
str_to_date(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = str_to_date(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;
```

---

### 3. Fix Null Values

Replaced empty values in `industry` with `NULL` and corrected some mismatched entries.

```sql
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';
```
Replace NULL values if we know the value from other rows.

```sql
UPDATE layoffs_staging2 as t1
JOIN layoffs_staging2 as t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE 
	t1.industry IS NULL
    AND t2.industry is NOT NULL;
```

---


### 4. Remove Rows Missing Key Values and Finalize Table

Remove rows where `total_laid_off` and `percentage_laid_off` are both NULL

```sql
DELETE 
FROM layoffs_staging2
WHERE 
	total_laid_off is NULL
    AND percentage_laid_off IS NULL;
```

Remove the `row_num` column.

```sql
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;
```
---

## Conclusion & Next Steps

After cleaning and preparing the layoff dataset, we now have a well-structured, standardized table that is ready for exploration and analysis. Duplicate entries were removed, inconsistent formats were corrected, missing values were addressed, and key fields were normalized for reliable use.

This cleaned dataset provides a solid foundation for deeper insights into global layoff trends, including:

- Tracking layoffs over time
- Identifying which industries are most impacted
- Analyzing layoffs by region or country
- Exploring company-level layoff behavior

### Next Steps

- Perform **Exploratory Data Analysis (EDA)** to uncover trends and outliers  
- Build **visual dashboards** using Tableau or Power BI  
- Create **SQL queries or Python scripts** to answer key business questions  
- Build **predictive models** to anticipate future layoffs based on trends  

This project will continue to develop as more time is dedicated to deeper analysis and visualization.
