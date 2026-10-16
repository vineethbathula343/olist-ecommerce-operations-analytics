/*
Project: Olist E-Commerce Operations & Customer Experience Analytics
File: 10_seller_performance.sql
Purpose: Analyse seller delivery performance, customer reviews,
         and order value.
Database: olist_analysis

Grain:
One row per seller in the output view.
Each seller-order combination is aggregated before calculating
seller-level metrics, avoiding repeated order-level review scores.
*/

USE olist_analysis;
GO

CREATE OR ALTER VIEW dbo.vw_seller_performance AS
WITH seller_order_metrics AS
(
    SELECT
        oi.seller_id,
        oi.order_id,
        SUM(oi.item_total_value) AS seller_order_value
    FROM dbo.olist_order_items_clean_dataset AS oi
    GROUP BY
        oi.seller_id,
        oi.order_id
)
SELECT
    som.seller_id,

    COUNT(*) AS total_orders,

    COUNT(CASE
        WHEN o.order_status = 'delivered' THEN 1
    END) AS delivered_orders,

    COUNT(CASE
        WHEN o.order_status = 'delivered'
         AND o.delivery_status = 'Late'
        THEN 1
    END) AS late_orders,

    COUNT(CASE
        WHEN o.order_status = 'delivered'
         AND o.delivery_status = 'Late'
        THEN 1
    END) * 100.0 /
    NULLIF(
        COUNT(CASE
            WHEN o.order_status = 'delivered' THEN 1
        END),
        0
    ) AS late_delivery_rate,

    AVG(CASE
        WHEN o.order_status = 'delivered'
        THEN o.avg_review_score
    END) AS average_review_score,

    SUM(som.seller_order_value) AS total_order_value

FROM seller_order_metrics AS som
INNER JOIN dbo.orders_master AS o
    ON som.order_id = o.order_id
GROUP BY
    som.seller_id;
GO


-- Review sellers with at least 100 delivered orders
SELECT
    seller_id,
    total_orders,
    delivered_orders,
    late_orders,
    late_delivery_rate,
    average_review_score,
    total_order_value
FROM dbo.vw_seller_performance
WHERE delivered_orders >= 100
ORDER BY
    late_delivery_rate DESC,
    delivered_orders DESC;


-- Identify sellers meeting both project risk criteria:
-- Late-delivery rate > 8.11% and average review score < 4.09
SELECT
    seller_id,
    delivered_orders,
    late_orders,
    late_delivery_rate,
    average_review_score,
    total_order_value
FROM dbo.vw_seller_performance
WHERE delivered_orders >= 100
  AND late_delivery_rate > 8.11
  AND average_review_score < 4.09
ORDER BY
    late_delivery_rate DESC,
    delivered_orders DESC;
