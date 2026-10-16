/*
Project: Olist E-Commerce Operations & Customer Experience Analytics
File: 07_delivery_performance.sql
Purpose: Analyse delivery-delay buckets and customer experience.
Database: olist_analysis

Interpretation:
- Delay days < 0 means delivered before the estimated date.
- Delay days > 0 means delivered after the estimated date.
- Low reviews are review scores of 1 or 2.
*/

USE olist_analysis;
GO

CREATE OR ALTER VIEW dbo.vw_delivery_delay_cx AS
WITH delivered_orders AS
(
    SELECT
        order_id,
        delivery_delay_days,
        avg_review_score,

        CASE
            WHEN delivery_delay_days <= -15 THEN '15+ Days Early'
            WHEN delivery_delay_days <= -7  THEN '7-14 Days Early'
            WHEN delivery_delay_days < 0    THEN '1-6 Days Early'
            WHEN delivery_delay_days = 0    THEN 'On Estimated Date'
            WHEN delivery_delay_days <= 3   THEN '1-3 Days Late'
            WHEN delivery_delay_days <= 7   THEN '4-7 Days Late'
            WHEN delivery_delay_days <= 14  THEN '8-14 Days Late'
            ELSE '15+ Days Late'
        END AS delivery_delay_bucket,

        CASE
            WHEN delivery_delay_days <= -15 THEN 1
            WHEN delivery_delay_days <= -7  THEN 2
            WHEN delivery_delay_days < 0    THEN 3
            WHEN delivery_delay_days = 0    THEN 4
            WHEN delivery_delay_days <= 3   THEN 5
            WHEN delivery_delay_days <= 7   THEN 6
            WHEN delivery_delay_days <= 14  THEN 7
            ELSE 8
        END AS delay_sort_order

    FROM dbo.orders_master
    WHERE order_status = 'delivered'
      AND delivery_delay_days IS NOT NULL
)
SELECT
    delivery_delay_bucket,
    delay_sort_order,
    COUNT(*) AS total_orders,
    AVG(avg_review_score) AS average_review_score,

    COUNT(CASE
        WHEN avg_review_score <= 2 THEN 1
    END) * 100.0 /
    NULLIF(
        COUNT(CASE
            WHEN avg_review_score IS NOT NULL THEN 1
        END),
        0
    ) AS low_review_rate

FROM delivered_orders
GROUP BY
    delivery_delay_bucket,
    delay_sort_order;
GO


-- Review delivery-delay and customer-experience results
SELECT
    delivery_delay_bucket,
    total_orders,
    average_review_score,
    low_review_rate
FROM dbo.vw_delivery_delay_cx
ORDER BY delay_sort_order;
