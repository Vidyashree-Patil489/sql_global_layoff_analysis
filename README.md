# Global Layoff Analysis using SQL

## 📌 Project Overview

This project analyzes a global layoffs dataset using MySQL.

The project focuses on two main areas:

- Data Cleaning
- Exploratory Data Analysis (EDA)

The goal is to transform raw layoff data into a cleaner and more structured dataset and then use SQL queries to identify trends and patterns in layoffs across companies, countries, industries, and years.

---

## 🛠️ Tools & Technologies

- MySQL
- MySQL Workbench
- SQL
- Git & GitHub

---

## 📂 Dataset

The dataset contains information about layoffs across different companies and locations.

Key columns include:

- Company
- Location
- Total Laid Off
- Date
- Percentage Laid Off
- Industry
- Source
- Stage
- Funds Raised
- Country
- Date Added

---

## 🧹 Data Cleaning

The data cleaning process includes:

- Creating staging tables to preserve the original dataset
- Identifying duplicate records
- Removing duplicate records using `ROW_NUMBER()`
- Standardizing text values using `TRIM()`
- Converting blank values to `NULL`
- Converting date values from text to the `DATE` data type
- Handling missing values
- Removing records where both `total_laid_off` and `percentage_laid_off` are missing
- Performing final validation checks

The cleaned dataset is stored in:

`layoffs_staging2`

---

## 📊 Exploratory Data Analysis

The EDA explores questions such as:

- What was the largest single layoff event?
- Which companies had the highest total layoffs?
- Which countries and locations had the most layoffs?
- How did layoffs change by year?
- Which industries experienced the most layoffs?
- Which company stages had the highest number of layoffs?
- Which companies had the most layoffs in each year?
- How did layoffs change month by month?
- What is the cumulative number of layoffs over time?
- Which records had the highest percentage of employees laid off?

---

## 🧠 SQL Concepts Used

This project uses a variety of SQL concepts, including:

- `SELECT`
- `WHERE`
- `GROUP BY`
- `HAVING`
- `ORDER BY`
- `LIMIT`
- Aggregate functions
- Common Table Expressions (CTEs)
- Window functions
- `ROW_NUMBER()`
- `DENSE_RANK()`
- `SUM() OVER()`
- Date functions
- Data cleaning and transformation
- Staging tables

---

## 📁 Project Structure

```text
sql_global_layoff_analysis/
│
├── 01_Data_Cleaning.sql
├── 02_EDA.sql
└── layoffs.csv
```

### `01_Data_Cleaning.sql`

Contains the complete data cleaning process, including duplicate removal, standardization, date conversion, and missing-value handling.

### `02_EDA.sql`

Contains SQL queries used to explore trends and patterns in the cleaned dataset.

### `layoffs.csv`

The raw dataset used for the analysis.

---

## ▶️ How to Run

1. Import `layoffs.csv` into MySQL.
2. Create/use the `world_layoffs` database.
3. Create the `layoffs` table using the dataset structure.
4. Run `01_Data_Cleaning.sql`.
5. Run `02_EDA.sql`.
6. Explore the results in MySQL Workbench.

---

## 📚 Reference

This project was developed as a hands-on SQL learning project and was adapted to work with the current version of the layoffs dataset.

The project structure and learning approach were inspired by Alex The Analyst's MySQL tutorial series.

Reference:

Alex The Analyst — MySQL YouTube Series

https://github.com/AlexTheAnalyst/MySQL-YouTube-Series

---

## 👩‍💻 Author

**Vidyashree Patil**

GitHub:

https://github.com/Vidyashree-Patil489
