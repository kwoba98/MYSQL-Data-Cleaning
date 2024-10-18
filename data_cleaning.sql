-- Switch to the layoffs_data database
use layoffs_data;

-- View all data in the layoffs table
select * from layoffs;

-- Step 1: Remove duplicates
-- Create a staging table with the same structure as layoffs
create table layoffs_staging like layoffs;

-- View the structure of the new staging table
select * from layoffs_staging;

-- Insert data from the layoffs table into the staging table
insert layoffs_staging select * from layoffs;

-- Use a common table expression (CTE) to identify duplicate rows
with duplicate_cte as (
  select *,
    -- Assign row numbers based on duplicates for each unique combination of these columns
    row_number() over (
      partition by company, location, industry, total_laid_off, percentage_laid_off, "date", stage, country, funds_raised_millions
    ) as row_num
  from layoffs_staging
)

-- Select rows where row_num > 1 (i.e., duplicates)
select * 
from duplicate_cte
where row_num > 1;

-- Create a second staging table for further processing
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

-- Insert data into the second staging table, including row_num to identify duplicates
insert into layoffs_staging2 
select *,
row_number() over (
  partition by company, location, industry, total_laid_off, percentage_laid_off, "date", stage, country, funds_raised_millions
) as row_num
from layoffs_staging;

-- Delete rows that have duplicates (row_num > 1)
delete from layoffs_staging2
where row_num > 1;

-- Verify deletion of duplicates
select * from layoffs_staging2
where row_num > 1;

-- Step 2: Standardize the data
-- Remove extra spaces from the company names
update layoffs_staging2
set company = TRIM(company);

-- Standardize industry names starting with "Crypto" to a uniform "Crypto"
update layoffs_staging2
set industry = "Crypto"
where industry like "Crypto%";

-- Standardize country names that start with "United States" and remove trailing periods
update layoffs_staging2
set country = trim(trailing "." from country)
where country like "United States%";

-- Convert date strings from 'mm/dd/yyyy' format to a proper date type
update layoffs_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y');

-- Change the date column type to DATE
alter table layoffs_staging2
modify column `date` date;

-- Step 3: Remove null/blank values
-- Identify rows where both total_laid_off and percentage_laid_off are null
select * 
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

-- Delete rows where both total_laid_off and percentage_laid_off are null
delete from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

-- Step 4: Remove any unnecessary columns (dropping row_num as it's no longer needed)
alter table layoffs_staging2
drop column row_num;

-- Create a new staging table without duplicates for final cleanup
CREATE TABLE `layoffs_staging3` (
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

-- Insert data into the third staging table and assign row_num to identify duplicates
insert into layoffs_staging3 
select *,
row_number() over (partition by company, location, industry, total_laid_off, percentage_laid_off, "date", stage, country, funds_raised_millions
) as row_num
from layoffs_staging;

-- Final cleanup: remove the row_num column from the final table
alter table layoffs_staging3
drop column row_num;
