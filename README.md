# **Layoffs Data Cleaning Script**

Project Overview
This MySQL script is designed to clean a dataset related to layoffs, ensuring the data is accurate, standardized, and ready for further analysis. It covers tasks such as removing duplicate entries, handling null values, standardizing data formats, and modifying table structures.

Dataset Description
The dataset contains the following columns:

company: Name of the company.
location: The location of the layoffs.
industry: The industry to which the company belongs.
total_laid_off: The total number of employees laid off.
percentage_laid_off: The percentage of the workforce that was laid off.
date: The date the layoffs occurred.
stage: The business stage of the company (e.g., early-stage, mature).
country: The country where the company is located.
funds_raised_millions: The total funds raised by the company in millions.
Key Steps in the Script

**The script performs the following operations:**

1. Removing Duplicate Records
Duplicates are identified based on several columns: company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, and funds_raised_millions.
Rows with the same values in these columns are assigned a row_num using the ROW_NUMBER() function.
Only the first occurrence of each unique combination is retained, and duplicates are removed.

2.Standardizing Data
Company Names: Extra spaces are trimmed to ensure consistent formatting.
Industry Names: Industries with inconsistent names are standardized (e.g., all names starting with "Crypto" are unified under "Crypto").
Country Names: The script removes trailing periods and ensures country names like "United States" are properly formatted.
Date Standardization: Dates are converted from mm/dd/yyyy string format to the SQL DATE format using the STR_TO_DATE() function.

3.Handling Null and Blank Values
Entries with null values in critical columns such as total_laid_off and percentage_laid_off are removed.
Blank entries in certain fields (like industry) are updated to NULL for consistency.

4.Column Modifications
The script alters column data types where necessary (e.g., converting date columns to SQL DATE type).
Unnecessary columns such as row_num (used for tracking duplicates) are dropped after data cleaning.

**Prerequisites**
MySQL: Ensure you have MySQL installed and configured.
Layoffs Dataset: A table named layoffs should be available in the database, with the specified columns.
Database: The script assumes you are working in a database called layoffs_data.

**How to Use**
Switch to the Database: The script begins by switching to the layoffs_data database.

**sql**
USE layoffs_data;
i. Create Staging Tables:
A staging table layoffs_staging is created as a working copy of the original data.
Later, additional staging tables (layoffs_staging2 and layoffs_staging3) are created for further processing and cleaning.

ii. Remove Duplicates:
The script identifies duplicate records using the ROW_NUMBER() function and deletes them from the staging table.

iii. Standardize Data:
Trimming white spaces from company names.
Updating inconsistent industry names and formatting country names.
Standardizing the date column by converting text dates to SQL DATE format.

iv.Handle Null/Blank Values:
Null or blank values in important fields are handled by either updating them or removing the records.

v.Final Cleanup:

The script performs final checks to ensure no duplicates remain and drops unnecessary columns like row_num.
Example Queries for Verification

To check if any duplicates remain:
**sql**
WITH duplicate_rows AS (
  SELECT *,
  ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
  FROM layoffs_staging3)
SELECT * FROM duplicate_rows WHERE row_num = 1;
To check if null or blank values exist in specific columns:

**sql**
SELECT * FROM layoffs_staging3 WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

Output
The final cleaned data is stored in the table layoffs_staging3. This table has:

Duplicate rows removed.
Standardized data across various columns.
Properly formatted date columns.
All null/blank values handled appropriately.

**Future Improvements**
Implement validation checks to verify the consistency and accuracy of the cleaned data.
Add logging for tracking changes made during the cleaning process.
Automate the cleaning process with a script that runs periodically.


Author: KWOBA FREDRICK
Date: 18 ‎October ‎2024
Contact: kwobafredrick98@gmail.com
