# SQL Business Analysis (MySQL)

A complete SQL project on a synthetic retail database: schema design, realistic seed data, and a documented set of analytical queries answering real business questions. Built and tested on MySQL 8.

## Business questions answered
1. What are total revenue, order count, and average order value?
2. How does revenue trend month over month?
3. Who are the top customers by lifetime revenue?
4. Which product categories bring the most revenue and the best margins?
5. What are the best-selling products?
6. How do repeat customers compare to one-time customers?
7. How many new customers does each month bring?
8. What are the cancellation and return rates?
9. Which cities generate the most revenue?
10. What does cumulative monthly revenue look like (window functions)?
11. How long does it take a new signup to place a first order?
12. Which products are frequently bought together?

## Repository contents
| Path | What it is |
|---|---|
| `sql/01_schema.sql` | Database and table definitions with keys, constraints, and indexes |
| `sql/02_seed_data.sql` | Synthetic seed data: 120 customers, 20 products, 400 orders, ~1,400 order items |
| `sql/03_analysis_queries.sql` | The 12 analysis queries above, each with a header comment |

## How to run
```bash
mysql -u root -p < sql/01_schema.sql
mysql -u root -p < sql/02_seed_data.sql
mysql -u root -p retail_business < sql/03_analysis_queries.sql
```

## Skills demonstrated
- Schema design: normalization, foreign keys, constraints, indexes
- Aggregations, multi-table joins, subqueries and derived tables
- Window functions for running totals
- Date arithmetic and cohort-style analysis
- Translating business questions into SQL
