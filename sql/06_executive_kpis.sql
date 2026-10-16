/*
Project: Olist E-Commerce Operations & Customer Experience Analytics
File: 06_executive_kpis.sql
Purpose: Calculate executive-level operational KPIs.
Database: olist_analysis
*/

USE olist_analysis;
GO

CREATE OR ALTER VIEW dbo.vw_executive_kpis AS
SELECT
    COUNT(*) AS total_orders,

    COUNT(CASE
        WHEN order_status = 'delivered' THEN 1
    END) AS delivered_orders,

    COUNT(CASE
        WHEN order_status = 'delivered' THEN 1
    END) * 100.0 /
        NULLIF(COUNT(*), 0) AS delivery_rate_pct,

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
        ) AS late_delivery_rate_pct,

    AVG(total_order_value) AS average_order_value,

    AVG(avg_review_score) AS average_review_score,

    AVG(
        CASE
            WHEN total_order_value > 0
            THEN total_freight_value * 100.0
                 / total_order_value
        END
    ) AS average_freight_burden_pct

FROM dbo.orders_master;
GO


-- Review the executive KPI results
SELECT *
FROM dbo.vw_executive_kpis;
