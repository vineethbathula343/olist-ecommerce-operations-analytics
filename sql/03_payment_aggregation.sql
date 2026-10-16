/*
Project: Olist E-Commerce Operations & Customer Experience Analytics
File: 03_payment_aggregation.sql
Purpose: Aggregate payment records to one row per order.
Database: olist_analysis
*/

USE olist_analysis;
GO

CREATE OR ALTER VIEW dbo.vw_payment_aggregation AS
SELECT
    order_id,
    COUNT(*) AS payment_count,
    COUNT(DISTINCT payment_type) AS distinct_payment_types,
    SUM(payment_value) AS total_payment_value,
    SUM(payment_installments) AS total_installments
FROM dbo.olist_order_payments_clean_dataset
GROUP BY order_id;
GO


-- Validate payment aggregation totals
SELECT
    COUNT(*) AS aggregated_order_count,
    COUNT(DISTINCT order_id) AS distinct_order_count,
    SUM(payment_count) AS total_payment_rows,
    SUM(total_payment_value) AS total_payment_value
FROM dbo.vw_payment_aggregation;


-- Confirm that each order appears once
SELECT
    order_id,
    COUNT(*) AS row_count
FROM dbo.vw_payment_aggregation
GROUP BY order_id
HAVING COUNT(*) > 1;
