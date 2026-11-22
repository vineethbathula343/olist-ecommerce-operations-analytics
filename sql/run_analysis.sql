-- Run from the repository root with sqlcmd -b -i sql/run_analysis.sql.
:ON ERROR EXIT
USE olist_analysis;
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;

IF OBJECT_ID(N'dbo.orders_master') IS NOT NULL
    THROW 50001, 'dbo.orders_master already exists. Use a fresh project database for a full build.', 1;

IF NOT EXISTS (SELECT 1 FROM dbo.olist_orders_clean_dataset)
    THROW 50002, 'Import the cleaned Olist orders before running the analysis.', 1;

BEGIN TRANSACTION;
GO

:r sql/01_data_validation.sql
GO
:r sql/02_order_item_aggregation.sql
GO
:r sql/03_payment_aggregation.sql
GO
:r sql/04_review_aggregation.sql
GO
:r sql/05_create_orders_master.sql
GO

IF EXISTS (SELECT 1 FROM dbo.orders_master WHERE order_id IS NULL)
    OR EXISTS (
        SELECT order_id FROM dbo.orders_master
        GROUP BY order_id HAVING COUNT_BIG(*) > 1
    )
    OR (SELECT COUNT_BIG(*) FROM dbo.orders_master)
       <> (SELECT COUNT_BIG(*) FROM dbo.olist_orders_clean_dataset)
    THROW 50003, 'orders_master failed its one-row-per-source-order validation.', 1;
GO

:r sql/06_executive_kpis.sql
GO
:r sql/07_delivery_performance.sql
GO
:r sql/08_state_delivery_analysis.sql
GO
:r sql/09_customer_analysis.sql
GO
:r sql/10_seller_performance.sql
GO
:r sql/11_category_performance.sql
GO
:r sql/12_monthly_operations.sql
GO
:r sql/13_business_insights.sql
GO

COMMIT TRANSACTION;
PRINT 'Olist analysis completed successfully.';
GO
