/*
Project: Olist E-Commerce Operations & Customer Experience Analytics
File: 01_data_validation.sql
Purpose: Validate imported table row counts and key uniqueness.
Database: olist_analysis
*/

USE olist_analysis;
GO

-- 1. Row counts for all imported tables
SELECT 'orders' AS table_name, COUNT_BIG(*) AS row_count
FROM dbo.olist_orders_clean_dataset

UNION ALL
SELECT 'order_items', COUNT_BIG(*)
FROM dbo.olist_order_items_clean_dataset

UNION ALL
SELECT 'payments', COUNT_BIG(*)
FROM dbo.olist_order_payments_clean_dataset

UNION ALL
SELECT 'reviews', COUNT_BIG(*)
FROM dbo.olist_order_reviews_clean_dataset

UNION ALL
SELECT 'products', COUNT_BIG(*)
FROM dbo.olist_products_clean_dataset

UNION ALL
SELECT 'sellers', COUNT_BIG(*)
FROM dbo.olist_sellers_clean_dataset

UNION ALL
SELECT 'customers', COUNT_BIG(*)
FROM dbo.olist_customers_clean_dataset

UNION ALL
SELECT 'geolocation', COUNT_BIG(*)
FROM dbo.olist_geolocation_clean_dataset

UNION ALL
SELECT 'category_translation', COUNT_BIG(*)
FROM dbo.product_category_name_clean_translation

ORDER BY table_name;


-- 2. Check for duplicate order IDs
SELECT
    'Duplicate order IDs' AS check_name,
    COUNT_BIG(*) AS issue_count
FROM (
    SELECT order_id
    FROM dbo.olist_orders_clean_dataset
    GROUP BY order_id
    HAVING COUNT(*) > 1
) AS duplicates;


-- 3. Check duplicate order-item keys
SELECT
    'Duplicate order-item keys' AS check_name,
    COUNT_BIG(*) AS issue_count
FROM (
    SELECT order_id, order_item_id
    FROM dbo.olist_order_items_clean_dataset
    GROUP BY order_id, order_item_id
    HAVING COUNT(*) > 1
) AS duplicates;


-- 4. Check duplicate payment keys
SELECT
    'Duplicate payment keys' AS check_name,
    COUNT_BIG(*) AS issue_count
FROM (
    SELECT order_id, payment_sequential
    FROM dbo.olist_order_payments_clean_dataset
    GROUP BY order_id, payment_sequential
    HAVING COUNT(*) > 1
) AS duplicates;


-- 5. Check duplicate review IDs
SELECT
    'Duplicate review IDs' AS check_name,
    COUNT_BIG(*) AS issue_count
FROM (
    SELECT review_id
    FROM dbo.olist_order_reviews_clean_dataset
    GROUP BY review_id
    HAVING COUNT(*) > 1
) AS duplicates;
