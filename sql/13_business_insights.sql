/*
Project: Olist E-Commerce Operations & Customer Experience Analytics
File: 13_business_insights.sql
Purpose: Consolidate key findings into business-facing analysis.
Database: olist_analysis

Important:
- Results are descriptive, not causal.
- Late-delivery rates in the analytical views are stored as
  percentage values (for example, 8.11 means 8.11%).
- High-risk seller criteria match the Power BI KPI:
  late-delivery rate > 8.11 and average review score < 4.09.
*/

USE olist_analysis;
GO

-- 1. Delivery delays and customer experience
SELECT
    delivery_delay_bucket,
    total_orders,
    average_review_score,
    low_review_rate
FROM dbo.vw_delivery_delay_cx
ORDER BY delay_sort_order;
GO


-- 2. Sellers meeting both high-risk criteria
SELECT
    COUNT(*) AS high_risk_sellers
FROM dbo.vw_seller_performance
WHERE late_delivery_rate > 8.11
  AND average_review_score < 4.09;
GO


-- 3. Highest late-delivery rates among meaningful-volume categories
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
ORDER BY late_delivery_rate DESC;
GO


-- 4. State-level delivery performance above the project benchmark
SELECT
    customer_state,
    delivered_orders,
    late_orders,
    late_delivery_rate,
    average_review_score
FROM dbo.vw_state_delivery
WHERE delivered_orders >= 100
  AND late_delivery_rate > 8.11
ORDER BY late_delivery_rate DESC;
GO


-- 5. Compare one-time and repeat customer behaviour
SELECT
    customer_type,
    COUNT(*) AS customer_count,
    AVG(CAST(total_orders AS DECIMAL(10, 2))) AS average_orders,
    AVG(total_spend) AS average_total_spend,
    AVG(avg_order_value) AS average_order_value,
    AVG(avg_review_score) AS average_review_score
FROM dbo.vw_customer_analysis
GROUP BY customer_type
ORDER BY customer_type;
GO
