-- Phase 0

USE Health_Data;

-- Phase 1 — Raw data checks (healthcare_dataset)

SELECT COUNT(*) AS raw_row_count FROM healthcare_dataset;
SELECT * FROM healthcare_dataset LIMIT 10;

-- Phase 2 — Staging (healthcare_staging, healthcare_staging2)

-- Copy raw data to  healthcare_staging
-- Identify duplicates with a window function
-- Create healthcare_staging2 with duplicates removed (keep first)

DROP TABLE IF EXISTS healthcare_staging;
CREATE TABLE healthcare_staging AS
SELECT * FROM healthcare_dataset;

WITH duplicate_cte AS (
  SELECT *, ROW_NUMBER() OVER(
    PARTITION BY Name, Age, Gender, `Blood Type`, `Medical Condition`,
                 `Date of Admission`, Doctor, Hospital, `Insurance Provider`,
                 `Billing Amount`, `Room Number`, `Admission Type`,
                 `Discharge Date`, Medication, `Test Results`
    ORDER BY Name
  ) AS row_num
  FROM healthcare_staging
)
SELECT * FROM duplicate_cte WHERE row_num > 1;

DROP TABLE IF EXISTS healthcare_staging2;
CREATE TABLE healthcare_staging2 AS
SELECT * FROM (
  SELECT *, ROW_NUMBER() OVER(
    PARTITION BY Name, Age, Gender, `Blood Type`, `Medical Condition`,
                 `Date of Admission`, Doctor, Hospital, `Insurance Provider`,
                 `Billing Amount`, `Room Number`, `Admission Type`,
                 `Discharge Date`, Medication, `Test Results`
    ORDER BY Name
  ) AS row_num
  FROM healthcare_staging
) t
WHERE row_num = 1;

-- Phase 3 — Cleaning & transformation (healthcare_staging2)

	-- Standardize names (trim, collapse spaces, proper case for two‑part names)
	-- Normalize providers (example: “UnitedHealthcare” → “United Health Care”)
	-- Enforce date types (Discharge Date to DATE)
	-- Handle blanks/NULLs (e.g., fallback Name = “Unknown”)
	-- Surface issues: missing admission dates, gender domain review, self‑matches, swapped names, infant‑age logic proxy
    
    -- standardize names
SET SQL_SAFE_UPDATES = 0;
UPDATE healthcare_staging2
SET Name = REGEXP_REPLACE(TRIM(Name),'[[:space:]]+',' ')
WHERE Name IS NOT NULL;

UPDATE healthcare_staging2
SET Name = CONCAT(
  UPPER(SUBSTRING(Name,1,1)),
  LOWER(SUBSTRING(Name,2,LOCATE(' ',Name)-1)),
  ' ',
  UPPER(SUBSTRING(Name,LOCATE(' ',Name)+1,1)),
  LOWER(SUBSTRING(Name,LOCATE(' ',Name)+2))
)
WHERE Name IS NOT NULL AND Name LIKE '% %';
SET SQL_SAFE_UPDATES = 1;

-- normalize insurance provider
SET SQL_SAFE_UPDATES = 0;
UPDATE healthcare_staging2
SET `Insurance Provider` = 'United Health Care'
WHERE `Insurance Provider` IN ('UnitedHealthcare','United-HealthCare');

-- convert to DATE
UPDATE healthcare_staging2
SET `Discharge Date` = STR_TO_DATE(`Discharge Date`,"%Y-%m-%d");
ALTER TABLE healthcare_staging2
MODIFY COLUMN `Discharge Date` DATE;

-- blanks/NULLs
UPDATE healthcare_staging2
SET Name = 'Unknown'
WHERE Name IS NULL OR Name = '';

-- data‑quality surfacing
SELECT * FROM healthcare_staging2
WHERE `Date of Admission` IS NULL;              -- missing admission date

SELECT DISTINCT Gender FROM healthcare_staging2; -- domain review

SELECT Name, Age, Gender, COUNT(*) AS cnt        -- self‑matches
FROM healthcare_staging2
GROUP BY Name, Age, Gender
HAVING cnt > 1;

-- swapped first/last name pattern
SELECT a.Name AS name1, b.Name AS name2
FROM healthcare_staging2 a
JOIN healthcare_staging2 b
  ON SUBSTRING_INDEX(a.Name,' ',1) = SUBSTRING_INDEX(b.Name,' ',-1)
 AND SUBSTRING_INDEX(a.Name,' ',-1) = SUBSTRING_INDEX(b.Name,' ',1)
WHERE a.Name <> b.Name;

-- infant‑age proxy (example logic)
SELECT Name, `Date of Admission`, `Discharge Date`
FROM healthcare_staging2
WHERE TIMESTAMPDIFF(YEAR, `Date of Admission`, `Discharge Date`) < 1;

-- Phase 4 — Final table (healthcare_cleaned)

DROP TABLE IF EXISTS healthcare_cleaned;
CREATE TABLE healthcare_cleaned AS
SELECT * FROM healthcare_staging2;

SELECT * FROM healthcare_cleaned LIMIT 20;

-- KPIs & quick QA queries

-- Total raw vs staging2 vs cleaned
SELECT 'raw' AS stage, COUNT(*) FROM healthcare_dataset
UNION ALL
SELECT 'staging2', COUNT(*) FROM healthcare_staging2
UNION ALL
SELECT 'cleaned', COUNT(*) FROM healthcare_cleaned;

-- Missing admission dates
SELECT COUNT(*) AS missing_admission_dates
FROM healthcare_staging2
WHERE `Date of Admission` IS NULL;

-- Self‑matches (potential duplicates remaining)
SELECT COUNT(*) AS self_match_groups
FROM (
  SELECT Name, Age, Gender
  FROM healthcare_staging2
  GROUP BY Name, Age, Gender
  HAVING COUNT(*) > 1
) x;

-- Distinct providers after normalization
SELECT COUNT(DISTINCT `Insurance Provider`) AS distinct_providers
FROM healthcare_staging2;