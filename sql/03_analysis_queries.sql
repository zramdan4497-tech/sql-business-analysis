USE retail_business;

-- Q1. Total revenue, orders, and average order value (completed orders only)
SELECT
    COUNT(DISTINCT o.order_id)                          AS orders,
    ROUND(SUM(oi.quantity * oi.unit_price), 2)          AS revenue,
    ROUND(SUM(oi.quantity * oi.unit_price)
          / COUNT(DISTINCT o.order_id), 2)              AS avg_order_value
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status = 'completed';

-- Q2. Monthly revenue trend
SELECT
    DATE_FORMAT(o.order_date, '%Y-%m')                  AS month,
    COUNT(DISTINCT o.order_id)                          AS orders,
    ROUND(SUM(oi.quantity * oi.unit_price), 2)          AS revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status = 'completed'
GROUP BY month
ORDER BY month;

-- Q3. Top 10 customers by lifetime revenue
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name)              AS customer,
    c.city,
    COUNT(DISTINCT o.order_id)                          AS orders,
    ROUND(SUM(oi.quantity * oi.unit_price), 2)          AS lifetime_revenue
FROM customers c
JOIN orders o       ON o.customer_id = c.customer_id AND o.status = 'completed'
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY c.customer_id, customer, c.city
ORDER BY lifetime_revenue DESC
LIMIT 10;

-- Q4. Revenue and gross margin by product category
SELECT
    p.category,
    ROUND(SUM(oi.quantity * oi.unit_price), 2)                       AS revenue,
    ROUND(SUM(oi.quantity * (oi.unit_price - p.unit_cost)), 2)       AS gross_profit,
    ROUND(100 * SUM(oi.quantity * (oi.unit_price - p.unit_cost))
               / SUM(oi.quantity * oi.unit_price), 1)                AS margin_pct
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
JOIN orders o   ON o.order_id = oi.order_id AND o.status = 'completed'
GROUP BY p.category
ORDER BY revenue DESC;

-- Q5. Best and worst selling products (units and revenue)
SELECT
    p.product_name,
    p.category,
    SUM(oi.quantity)                                AS units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price), 2)      AS revenue
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
JOIN orders o   ON o.order_id = oi.order_id AND o.status = 'completed'
GROUP BY p.product_id, p.product_name, p.category
ORDER BY revenue DESC
LIMIT 10;

-- Q6. Repeat vs one-time customers
SELECT
    CASE WHEN order_count > 1 THEN 'repeat' ELSE 'one-time' END AS customer_type,
    COUNT(*)                                                     AS customers,
    ROUND(AVG(total_spent), 2)                                   AS avg_spent
FROM (
    SELECT
        o.customer_id,
        COUNT(DISTINCT o.order_id)                    AS order_count,
        SUM(oi.quantity * oi.unit_price)              AS total_spent
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'completed'
    GROUP BY o.customer_id
) t
GROUP BY customer_type;

-- Q7. Monthly new vs returning customers
SELECT
    DATE_FORMAT(first_orders.first_month, '%Y-%m')  AS cohort_month,
    COUNT(*)                                        AS new_customers
FROM (
    SELECT customer_id, MIN(order_date) AS first_month
    FROM orders
    WHERE status = 'completed'
    GROUP BY customer_id
) first_orders
GROUP BY cohort_month
ORDER BY cohort_month;

-- Q8. Cancellation and return rates
SELECT
    status,
    COUNT(*)                                   AS orders,
    ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM orders), 1) AS pct_of_all
FROM orders
GROUP BY status;

-- Q9. City-level revenue ranking
SELECT
    c.city,
    COUNT(DISTINCT o.order_id)                 AS orders,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM customers c
JOIN orders o       ON o.customer_id = c.customer_id AND o.status = 'completed'
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY c.city
ORDER BY revenue DESC;

-- Q10. Running monthly revenue with a window function
SELECT
    month,
    revenue,
    ROUND(SUM(revenue) OVER (ORDER BY month), 2) AS running_revenue
FROM (
    SELECT
        DATE_FORMAT(o.order_date, '%Y-%m')              AS month,
        SUM(oi.quantity * oi.unit_price)                AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'completed'
    GROUP BY month
) m
ORDER BY month;

-- Q11. Average days between signup and first order
SELECT
    ROUND(AVG(DATEDIFF(first_order.first_date, c.signup_date)), 1) AS avg_days_to_first_order
FROM customers c
JOIN (
    SELECT customer_id, MIN(order_date) AS first_date
    FROM orders
    WHERE status = 'completed'
    GROUP BY customer_id
) first_order ON first_order.customer_id = c.customer_id;

-- Q12. Products frequently bought together (top pairs)
SELECT
    p1.product_name AS product_a,
    p2.product_name AS product_b,
    COUNT(*)        AS times_together
FROM order_items a
JOIN order_items b
  ON a.order_id = b.order_id AND a.product_id < b.product_id
JOIN products p1 ON p1.product_id = a.product_id
JOIN products p2 ON p2.product_id = b.product_id
JOIN orders o    ON o.order_id = a.order_id AND o.status = 'completed'
GROUP BY product_a, product_b
ORDER BY times_together DESC
LIMIT 10;
