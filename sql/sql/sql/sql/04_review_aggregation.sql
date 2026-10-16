/*
Project: Olist E-Commerce Operations & Customer Experience Analytics
File: 04_review_aggregation.sql
Purpose: Aggregate review records to one row per order.
Database: olist_analysis
*/

USE olist_analysis;
GO

CREATE OR ALTER VIEW dbo.vw_review_aggregation AS
SELECT
    order_id,
    COUNT(*) AS review_count,
    AVG(CAST(review_score AS DECIMAL(3, 2))) AS avg_review_score,
    COUNT(CASE WHEN review_score <= 2 THEN 1 END) AS low_review_count
FROM dbo.olist_order_reviews_clean_dataset
GROUP BY order_id;
GO


-- Validate the review aggregation totals
SELECT
    COUNT(*) AS aggregated_order_count,
    COUNT(DISTINCT order_id) AS distinct_order_count,
    SUM(review_count) AS total_review_rows,
    AVG(avg_review_score) AS average_order_level_review_score
FROM dbo.vw_review_aggregation;


-- Confirm that each order appears once
SELECT
    order_id,
    COUNT(*) AS row_count
FROM dbo.vw_review_aggregation
GROUP BY order_id
HAVING COUNT(*) > 1;
