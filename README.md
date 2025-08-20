Project Overview

This project demonstrates my work in data cleaning and data quality validation using SQL, applied to a healthcare dataset. The primary objective was to improve the dataset’s accuracy, consistency, and reliability by addressing common healthcare data issues such as:

	•	Duplicate patient records
	•	Inconsistent formatting (names, insurance providers, dates)
	•	Missing or null values
	•	Invalid demographic details (e.g., mismatched gender values)
	•	Transposed or self-matching records

Approach -

Using SQL-based techniques, I designed a multi-phase workflow:

	1.	Raw Data Load – Imported the healthcare dataset into a raw table for baseline analysis.
 
	2.	Staging & Deduplication – Created staging tables, detected duplicates using window functions, and retained unique rows.
 
	3.	Cleaning & Standardization –
	•	Standardized patient names (proper case, trimmed spaces).
	•	Normalized provider names (e.g., “UnitedHealthcare” → “United Health Care”).
	•	Converted text dates into SQL DATE types.
	•	Replaced nulls/blanks with consistent placeholder values.
 
	4.	Data Validation – Ran queries to flag:
	•	Missing admission dates
	•	Invalid/mismatched gender values
	•	Self-matches (same demographics, multiple entries)
	•	Transposed names (first/last swapped)
	•	Odd admission/discharge logic (e.g., stays under one year for flagged review)
 
	5.	Final Clean Table – Materialized a fully cleaned and query-optimized dataset for downstream analytics and reporting.

Outcomes - 

	•	Improved data integrity: Reduced duplicates and enforced consistent formats.
	•	Higher usability: Created a standardized dataset ready for BI tools (e.g., Power BI, Tableau, Excel).
	•	Repeatable process: Script designed in phases so it can be rerun on new raw data.
	•	Validation insights: Exposed common healthcare data quality issues that can be monitored via dashboards.


KPIs (Key Performance Indicators) -

To measure the success of the data cleaning process, I tracked the following KPIs:

	•	Duplicate Reduction Rate – % of duplicate rows removed compared to raw dataset.
	•	Null/Blank Field Coverage – % decrease in missing values for critical fields (Name, Admission Date, Discharge Date).
	•	Standardization Rate – % of standardized provider names and name formats vs. raw.
	•	Data Type Accuracy – % of date fields successfully converted to DATE format.
	•	Validation Flags – Number of records flagged for demographic issues (e.g., invalid gender values, transposed names, self-matches).

These KPIs quantify improvements in accuracy, completeness, and consistency of the dataset.

Quick QA Checks - 

To validate the cleaned dataset, I performed fast QA checks, such as:

	•	Row Count Comparison – Confirm cleaned dataset has fewer rows (after duplicate removal) but still retains all unique patient records.
	•	Distinct Value Checks – Ensured standardized values (e.g., "United Health Care" appears consistently, no variants).
	•	Data Type Verification – Confirmed all Discharge Date values are valid SQL DATEs.
	•	Outlier Detection – Checked for odd admission/discharge timelines and unrealistic age values.
	•	Referential Logic – Ensured no patients had admission dates after discharge dates.

These QA checks ensure that the cleaned dataset is fit for analytics and doesn’t introduce new errors during the transformation.

Key Skills Demonstrated -

	•	SQL (window functions, regex, string manipulation, date conversion)
	•	Data cleaning & transformation
	•	Data quality validation & QA checks
	•	Healthcare domain knowledge (admission/discharge, demographic validation)
	•	Preparing datasets for analytics & reporting

Conclusion -

This project demonstrates the importance of data cleaning and quality validation in maintaining the integrity of healthcare datasets. Using SQL-based techniques, I transformed a raw, inconsistent dataset into a structured, standardized, and reliable source of truth for downstream analytics and reporting.

By systematically addressing duplicates, nulls, formatting issues, and validation checks, I showcased how even messy healthcare data can be made ready for decision-making and compliance reporting.

Future Work -

	•	Power BI Dashboards: I plan to connect the cleaned dataset to Power BI and build interactive dashboards to highlight key quality metrics, patient demographics, and trends.
	
