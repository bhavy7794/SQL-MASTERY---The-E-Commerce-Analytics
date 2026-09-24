# 🛒 SQL Mastery – E-Commerce Analytics

A comprehensive SQL project based on the **Brazilian E-Commerce Public Dataset by Olist**.  
This project focuses on database design, data cleaning, analytical SQL, advanced window functions, stored procedures, and query optimization using MySQL.

---

## 📌 Project Overview

In this project, I worked with raw e-commerce transactional data from multiple CSV files and developed a structured SQL analytics solution.

The project covers the complete workflow from:

**Raw Data → Data Quality → Database Design → Data Cleaning → SQL Analysis → Advanced Analytics → Optimization**

The analysis is performed using **MySQL**.

---

## 🎯 Objectives

- Design a normalized e-commerce database
- Analyze and document raw data quality issues
- Clean and validate transactional data
- Implement SQL queries for business analysis
- Use joins, subqueries, CTEs, and window functions
- Perform customer and seller analysis
- Analyze revenue and purchasing patterns
- Create stored procedures
- Optimize SQL queries using indexes and `EXPLAIN ANALYZE`

---

## 📊 Dataset

The project uses the:

**Brazilian E-Commerce Public Dataset by Olist**

The dataset contains approximately **100K orders** across multiple CSV files.

### Dataset Tables

| Table | Description |
|---|---|
| `olist_customers_dataset` | Customer information |
| `olist_orders_dataset` | Order information and timestamps |
| `olist_order_items_dataset` | Products included in orders |
| `olist_products_dataset` | Product information |
| `olist_sellers_dataset` | Seller information |
| `olist_order_payments_dataset` | Payment information |
| `olist_order_reviews_dataset` | Customer reviews |
| `olist_geolocation_dataset` | Brazilian geolocation information |

> The raw CSV files are not included in this repository.

---

## 🛠️ Technologies Used

- **MySQL**
- SQL
- MySQL Workbench
- CTEs
- Window Functions
- Aggregate Functions
- Joins
- Subqueries
- Stored Procedures
- Indexes
- `EXPLAIN ANALYZE`

---

# 📚 Assignment Sections

## Part A – Database Design & Data Quality

Topics covered:

- 3NF database design
- ERD creation
- Data type selection
- Primary and foreign keys
- Database constraints
- Duplicate detection
- Data quality analysis
- Data dictionary

### Data Quality Checks

Examples of issues investigated:

- NULL values
- Duplicate records
- Encoding issues
- Invalid or inconsistent text values
- Missing relationships
- Invalid dates
- Orphan records
- Data consistency problems

---

## Part B – Data Manipulation & Retrieval

Implemented:

- Transactions
- `COMMIT`
- `ROLLBACK`
- Orphan record detection
- Customers without orders
- Payment/order total comparison
- Data validation queries

---

## Part C – Complex Aggregations

Implemented analytical queries for:

- Monthly revenue
- Month-over-Month growth
- Top products by category
- Customer Lifetime Value
- Customer segmentation
- Sales reports using `ROLLUP`
- Seasonal sales patterns

---

## Part D – Mastering Joins

Implemented:

- Customer 360-degree analysis
- Category-based customer analysis
- Seller and product performance
- Market basket analysis
- Shipping delay analysis

SQL techniques used include:

- `INNER JOIN`
- `LEFT JOIN`
- Self-joins
- Multiple-table joins
- CTEs

---

## Part E – Subqueries & CTEs

Implemented:

- Customers spending above their state average
- Second-highest revenue-generating products
- Consecutive-month purchasing analysis
- Common Table Expressions

A recursive category hierarchy was not implemented because the Olist product-category data does not provide a parent-child category hierarchy.

---

## Part F – Advanced Window Functions

Implemented:

### 7-Day Moving Average

Used:

```sql
AVG() OVER()