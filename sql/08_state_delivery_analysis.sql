/*
Project: Olist E-Commerce Operations & Customer Experience Analytics
File: 08_state_delivery_analysis.sql
Purpose: Compare delivery performance across customer states.
Database: olist_analysis

Late-delivery rate denominator:
Delivered orders within each state.

Interpretation:
State comparisons are descriptive. Low-volume states
should be interpreted cautiously.
*/

USE olist_analysis;
GO

CREATE OR ALTER VIEW dbo.vw_state_delivery AS
SELECT
    customer_state,

    COUNT(CASE
        WHEN order_status = 'delivered' THEN 1
    END) AS delivered_orders,

    COUNT(CASE
        WHEN order_status = 'delivered'
         AND delivery_status = 'Late'
        THEN 1
    END) AS late_orders,

    COUNT(CASE
        WHEN order_status = 'delivered'
         AND delivery_status = 'Late'
        THEN 1
    END) * 100.0 /
    NULLIF(
        COUNT(CASE
            WHEN order_status = 'delivered' THEN 1
        END),
        0
    ) AS late_delivery_rate,

    AVG(CASE
        WHEN order_status = 'delivered'
        THEN avg_review_score
    END) AS average_review_score,

    AVG(CASE
        WHEN order_status = 'delivered'
         AND total_order_value > 0
        THEN total_freight_value * 100.0
             / total_order_value
    END) AS average_freight_burden_pct

FROM dbo.orders_master
GROUP BY customer_state;
GO


-- Review state-level delivery performance
SELECT
    customer_state,
    delivered_orders,
    late_orders,
    late_delivery_rate,
    average_review_score,
    average_freight_burden_pct
FROM dbo.vw_state_delivery
ORDER BY late_delivery_rate DESC;


-- Identify states with elevated late-delivery rates.
-- Use a 100-delivered-order minimum to reduce small-sample effects.
SELECT
    customer_state,
    delivered_orders,
    late_orders,
    late_delivery_rate,
    average_review_score
FROM dbo.vw_state_delivery
WHERE delivered_orders >= 100
ORDER BY late_delivery_rate DESC;
