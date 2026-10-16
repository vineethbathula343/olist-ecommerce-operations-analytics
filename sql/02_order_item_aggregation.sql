/*
Project: Olist E-Commerce Operations & Customer Experience Analytics
File: 02_order_item_aggregation.sql
Purpose: Aggregate order-item records to one row per order.
Database: olist_analysis
*/

USE olist_analysis;
GO

CREATE OR ALTER VIEW dbo.vw_order_item_aggregation AS
SELECT
    order_id,
    COUNT(*) AS item_count,
    COUNT(DISTINCT product_id) AS distinct_product_count,
    COUNT(DISTINCT seller_id) AS distinct_seller_count,
    SUM(price) AS total_product_price,
    SUM(freight_value) AS total_freight_value,
    SUM(item_total_value) AS total_order_value
FROM dbo.olist_order_items_clean_dataset
GROUP BY order_id;
GO


-- Validate the aggregation grain and totals
SELECT
    COUNT(*) AS aggregated_order_count,
    COUNT(DISTINCT order_id) AS distinct_order_count,
    SUM(item_count) AS total_item_rows,
    SUM(total_product_price) AS total_product_price,
    SUM(total_freight_value) AS total_freight_value,
    SUM(total_order_value) AS total_order_value
FROM dbo.vw_order_item_aggregation;


-- Check that the aggregation returns one row per order
SELECT
    order_id,
    COUNT(*) AS row_count
FROM dbo.vw_order_item_aggregation
GROUP BY order_id
HAVING COUNT(*) > 1;
