/*
Project: Olist E-Commerce Operations & Customer Experience Analytics
File: 11_category_performance.sql
Purpose: Compare category demand, order value, delivery performance,
         and customer experience.
Database: olist_analysis

Grain:
One row per product category.

Important:
An order containing multiple categories contributes to each
relevant category's order count. Category-level order counts
therefore should not be summed to obtain distinct business-wide orders.
*/

USE olist_analysis;
GO

CREATE OR ALTER VIEW dbo.vw_category_performance AS

WITH item_category AS
(
    SELECT
        oi.order_id,
        oi.order_item_id,
        oi.product_id,
        oi.item_total_value,

        COALESCE(
            NULLIF(t.column2, ''),
            NULLIF(p.product_category_name, ''),
            'Unknown'
        ) AS category_name

    FROM dbo.olist_order_items_clean_dataset AS oi

    LEFT JOIN dbo.olist_products_clean_dataset AS p
        ON oi.product_id = p.product_id

    LEFT JOIN dbo.product_category_name_clean_translation AS t
        ON p.product_category_name = t.column1
),

category_orders AS
(
    SELECT DISTINCT
        order_id,
        category_name
    FROM item_category
),

order_metrics AS
(
    SELECT
        co.category_name,

        COUNT(*) AS total_orders,

        COUNT(CASE
            WHEN o.order_status = 'delivered' THEN 1
        END) AS delivered_orders,

        COUNT(CASE
            WHEN o.order_status = 'delivered'
             AND o.delivery_status = 'Late'
            THEN 1
        END) AS late_orders,

        AVG(CASE
            WHEN o.order_status = 'delivered'
            THEN o.avg_review_score
        END) AS average_review_score

    FROM category_orders AS co

    INNER JOIN dbo.orders_master AS o
        ON co.order_id = o.order_id

    GROUP BY co.category_name
),

item_metrics AS
(
    SELECT
        category_name,
        COUNT(*) AS item_count,
        SUM(item_total_value) AS total_category_value,
        AVG(item_total_value) AS average_item_value

    FROM item_category
    GROUP BY category_name
)

SELECT
    i.category_name,
    o.total_orders,
    o.delivered_orders,
    o.late_orders,

    o.late_orders * 100.0 /
        NULLIF(o.delivered_orders, 0) AS late_delivery_rate,

    o.average_review_score,
    i.item_count,
    i.total_category_value,
    i.average_item_value

FROM item_metrics AS i

INNER JOIN order_metrics AS o
    ON i.category_name = o.category_name;
GO


-- Review category-level performance
SELECT
    category_name,
    total_orders,
    delivered_orders,
    late_orders,
    late_delivery_rate,
    average_review_score,
    item_count,
    total_category_value,
    average_item_value
FROM dbo.vw_category_performance
ORDER BY total_category_value DESC;


-- Identify categories with at least 1,000 orders and
-- late-delivery rates above the overall project benchmark.
SELECT
    category_name,
    total_orders,
    delivered_orders,
    late_orders,
    late_delivery_rate,
    average_review_score,
    total_category_value
FROM dbo.vw_category_performance
WHERE total_orders >= 1000
  AND late_delivery_rate > 8.11
ORDER BY late_delivery_rate DESC;
