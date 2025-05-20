# 📊 AdventureWorks 2005 SQL Analysis Project

This repository contains the solution to a graded SQL exercise for Turing College’s Data Analytics Program. The project focuses on answering specific business questions by querying the **AdventureWorks 2005** database using **Google BigQuery**.

## 🚀 Objective

The goal of this exercise is to demonstrate proficiency in SQL by:
- Exploring and understanding a real-world relational database
- Writing and optimizing queries across multiple tables
- Applying data transformation and filtering logic
- Delivering actionable business insights based on data

> **Database Access**: The `adwentureworks_db` (not the v19 version) is accessed via BigQuery using the credentials provided by Turing College.

---

## 📁 Project Structure

This repository contains:
- `queries/`: A folder containing `.sql` files for each subtask
- `results/`: A link to the Google Spreadsheet containing query results and corresponding queries
- `README.md`: Project overview and guidance

📄 **[Google Spreadsheet with Results & Queries]((https://docs.google.com/spreadsheets/d/149KaaUN2O7ah96FqraifyGS2hFT3hqgILy0rYJwIn1Y/edit?usp=sharing))**

---

## 🧠 Tasks Overview

### **1. Customer Analysis**

| Task | Description |
|------|-------------|
| 1.1  | Overview of all individual customers with address and sales metrics |
| 1.2  | Top 200 customers (by total amount) who haven’t ordered in the last 365 days |
| 1.3  | Adds an “Active/Inactive” status to the 1.1 query |
| 1.4  | Filter to active North American customers with address parsing |

---

### **2. Sales Reporting**

| Task | Description |
|------|-------------|
| 2.1  | Monthly sales by country and region |
| 2.2  | Adds cumulative total amount per country/region |
| 2.3  | Adds sales rank per region and month |
| 2.4  | Adds tax insights: average rate & province coverage per country |

---

## 📌 Evaluation Criteria

- **Effort & Creativity**: Demonstrated use of joins, CTEs, and logical problem-solving
- **Formatting & Readability**: Clean code with meaningful comments
- **Validation**: Clear logic and methods to verify query results
- **Understanding**: Strong grasp of SQL fundamentals, relationships, and data context

---

## 🧰 Tools & Resources

- **SQL Engine**: Google BigQuery
- **Database**: `adwentureworks_db` (AdventureWorks 2005)
- **Spreadsheet**: Google Sheets for query/result storage
- **Documentation**: BigQuery SQL syntax & functions
