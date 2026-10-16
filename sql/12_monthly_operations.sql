/*
Project: Olist E-Commerce Operations & Customer Experience Analytics
File: 12_monthly_operations.sql
Purpose: Analyse monthly order volume, delivery performance,
         order value, and customer review scores.
Database: olist_analysis

Late-delivery rate denominator:
Delivered orders only.
*/

USE olist_analysis;
GO

CREATE OR ALTER VIEW dbo.vw_monthly_operations AS
SELECT
    DATEFROMPARTS(
        YEAR(order_purchase_timestamp),
        MONTH(order_purchase_timestamp),
        1
    ) AS month_start,

    YEAR(order_purchase_timestamp) AS order_year,
    MONTH(order_purchase_timestamp) AS order_month,

    COUNT(*) AS total_orders,

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

    AVG(total_order_value) AS average_order_value,

    AVG(avg_review_score) AS average_review_score

FROM dbo.orders_master

GROUP BY
    YEAR(order_purchase_timestamp),
    MONTH(order_purchase_timestamp);
GO


-- Review monthly trends in chronological order
SELECT
    month_start,
    total_orders,
    delivered_orders,
    late_orders,
    late_delivery_rate,
    average_order_value,
    average_review_score
FROM dbo.vw_monthly_operations
ORDER BY month_start;
