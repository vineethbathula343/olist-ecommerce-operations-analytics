/*
Project: Olist E-Commerce Operations & Customer Experience Analytics
File: 05_create_orders_master.sql
Purpose: Build an order-level analytical master table.
Database: olist_analysis

Dependencies:
- 02_order_item_aggregation.sql
- 03_payment_aggregation.sql
- 04_review_aggregation.sql

Important:
Run this script only when dbo.orders_master does not already exist.
It uses SELECT INTO to create the table.
*/

USE olist_analysis;
GO

SELECT
    o.*,

    -- Customer attributes
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,

    -- Order-item aggregates
    i.item_count,
    i.distinct_product_count,
    i.distinct_seller_count,
    i.total_product_price,
    i.total_freight_value,
    i.total_order_value,

    -- Payment aggregates
    p.payment_count,
    p.total_payment_value,

    -- Review aggregates
    r.review_count,
    r.avg_review_score,
    r.low_review_count

INTO dbo.orders_master

FROM dbo.olist_orders_clean_dataset AS o

LEFT JOIN dbo.vw_order_item_aggregation AS i
    ON o.order_id = i.order_id

LEFT JOIN dbo.vw_payment_aggregation AS p
    ON o.order_id = p.order_id

LEFT JOIN dbo.vw_review_aggregation AS r
    ON o.order_id = r.order_id

LEFT JOIN dbo.olist_customers_clean_dataset AS c
    ON o.customer_id = c.customer_id;
GO


-- Validate the master table row count and grain
SELECT
    COUNT_BIG(*) AS master_row_count,
    COUNT(DISTINCT order_id) AS distinct_order_count
FROM dbo.orders_master;


-- Check for duplicate order IDs
SELECT
    order_id,
    COUNT(*) AS row_count
FROM dbo.orders_master
GROUP BY order_id
HAVING COUNT(*) > 1;
