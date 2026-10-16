/*
Project: Olist E-Commerce Operations & Customer Experience Analytics
File: 09_customer_analysis.sql
Purpose: Analyse one-time and repeat customer behaviour.
Database: olist_analysis

Customer definition:
A repeat customer has more than one order under the same
customer_unique_id.

Average spend excludes customers with NULL total_spend.
*/

USE olist_analysis;
GO

CREATE OR ALTER VIEW dbo.vw_customer_analysis AS
WITH customer_orders AS
(
    SELECT
        customer_unique_id,
        COUNT(*) AS total_orders,
        SUM(total_order_value) AS total_spend,
        AVG(total_order_value) AS avg_order_value,
        AVG(avg_review_score) AS avg_review_score
    FROM dbo.orders_master
    WHERE customer_unique_id IS NOT NULL
    GROUP BY customer_unique_id
)
SELECT
    customer_unique_id,
    total_orders,

    CASE
        WHEN total_orders > 1 THEN 'Repeat Customer'
        ELSE 'One-Time Customer'
    END AS customer_type,

    total_spend,
    avg_order_value,
    avg_review_score

FROM customer_orders;
GO


-- Customer classification and repeat-customer rate
SELECT
    COUNT(*) AS unique_customers,

    COUNT(CASE
        WHEN customer_type = 'Repeat Customer' THEN 1
    END) AS repeat_customers,

    COUNT(CASE
        WHEN customer_type = 'One-Time Customer' THEN 1
    END) AS one_time_customers,

    COUNT(CASE
        WHEN customer_type = 'Repeat Customer' THEN 1
    END) * 100.0 /
        NULLIF(COUNT(*), 0) AS repeat_customer_rate_pct

FROM dbo.vw_customer_analysis;


-- Average total spend per repeat customer
-- Customers with NULL total_spend are excluded.
SELECT
    COUNT(*) AS repeat_customer_count,
    COUNT(total_spend) AS repeat_customers_with_spend,
    AVG(total_spend) AS avg_repeat_customer_spend
FROM dbo.vw_customer_analysis
WHERE customer_type = 'Repeat Customer';


-- Compare customer types
SELECT
    customer_type,
    COUNT(*) AS customer_count,
    AVG(total_orders * 1.0) AS average_orders,
    AVG(total_spend) AS average_total_spend,
    AVG(avg_order_value) AS average_order_value,
    AVG(avg_review_score) AS average_review_score
FROM dbo.vw_customer_analysis
GROUP BY customer_type
ORDER BY customer_type;
