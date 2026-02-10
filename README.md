# Amazon-Sales-Data-Analysis
End-to-end SQL analytics project on a multi-table Amazon sales dataset, solving real business problems using advanced SQL (CTEs, window functions, ranking, conditional aggregation). Focused on revenue, customer behavior, product performance, and regional insights.

# Amazon Sales Analytics using Advanced SQL

## 📌 Project Overview
This project is an **end-to-end SQL-based business analytics case study** built on a multi-table Amazon sales dataset. The objective is to replicate **real-world analytical problem solving** by answering high-impact business questions related to sales performance, customer behavior, product categories, payments, and regional trends.

The analysis is performed using **advanced SQL techniques** across **nine relational tables**, closely mirroring the complexity of production-grade e-commerce databases.

> The focus of this project is not just writing SQL queries, but **deriving actionable business insights**.

---

## 🧠 Business Problems Addressed
The project is structured around **21 real-world business questions**, out of which **10–12 have been fully implemented and analyzed so far** (with ongoing additions).

Key problem areas include:
- Identifying top- and bottom-performing product categories
- State-wise and region-wise sales performance analysis
- Customer purchase and repeat-order behavior
- Payment success and failure distribution
- Revenue contribution by customer segments
- Ranking-based and comparative analysis across dimensions

Each query is framed from a **decision-making perspective**, similar to how analytics is performed in industry settings.

---

## 🔑 Key Insights (Sample)
- A small subset of product categories contributes a disproportionately large share of overall revenue.
- Certain states generate high order volumes but exhibit lower average order values, indicating regional pricing or product-mix differences.
- Repeat customers represent a smaller portion of the user base but account for a significantly higher share of total revenue.
- Payment methods show noticeable variation in failure and drop-off rates.
- Least-selling categories vary significantly by state, highlighting the need for localized inventory and marketing strategies.

_All insights are derived using SQL-only analysis._

---

## 🗄️ Dataset & Schema
- **Domain:** E-commerce / Retail Analytics  
- **Number of tables:** 9  
- **Data characteristics:**
  - Orders, customers, sellers, products, categories, payments, and order items
  - One-to-many and many-to-many relationships
  - Transaction-level data with temporal attributes

An **ERD diagram** is included in the repository to illustrate table relationships and join paths clearly.

---

## ⚙️ SQL Techniques & Concepts Used
This project deliberately applies **advanced SQL concepts expected in data analyst and analytics roles**, including:

- Common Table Expressions (CTEs)
- Window functions (`RANK`, `DENSE_RANK`, `ROW_NUMBER`)
- Conditional aggregation using `CASE WHEN`
- Percentage and contribution analysis
- Multi-table joins across normalized schemas
- Partition-based ranking and filtering
- Time-based aggregations and comparisons
- Business-rule-driven query logic

---

## 📁 Repository Structure
```text
├── README.md
├── amazon_sales_data_analysis.sql
├── docs/
│   └── ERD_Diagram.png
