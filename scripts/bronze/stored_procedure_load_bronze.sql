/*====================================================================================================================
    STORED PROCEDURE : bronze.load_bronze_layer
    AUTHOR           : Tharuka Harshajith - Data Engineer

    DESCRIPTION      :
        This stored procedure loads all raw datasets into the Bronze layer of the Olist Data Warehouse.

        Key Features:
        -----------------------------------------------------------------------------------------
        1. Loads all CSV files using BULK INSERT
        2. Truncates tables before reload (full refresh strategy)
        3. Measures execution time per dataset
        4. Measures total Bronze layer load time
        5. Includes error handling per table (fault isolation)
        6. Logs success/failure messages for monitoring

        Bronze Layer Purpose:
        -----------------------------------------------------------------------------------------
        - Stores raw ingested data as-is from source systems
        - No transformations applied
        - Acts as landing zone for ETL pipeline

====================================================================================================================*/

CREATE OR ALTER PROCEDURE bronze.load_bronze_layer
AS
BEGIN
    SET NOCOUNT ON;

    ------------------------------------------------------
    -- Start Total Timer
    ------------------------------------------------------
    DECLARE @layer_start_time DATETIME = GETDATE();

    PRINT '======================================================';
    PRINT '===== BRONZE LAYER LOAD STARTED =====';
    PRINT '======================================================';

    /*====================================================================
        1. olist_customers_dataset
    ====================================================================*/
    BEGIN TRY
        DECLARE @start_time DATETIME = GETDATE();

        PRINT 'Loading: olist_customers_dataset';

        TRUNCATE TABLE bronze.olist_customers_dataset;

        BULK INSERT bronze.olist_customers_dataset
        FROM 'D:\For_Job\Data_Engineering_Project\olis\olist_customers_dataset.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            CODEPAGE = '65001',
            TABLOCK
        );

        PRINT 'SUCCESS: olist_customers_dataset loaded';

        PRINT CONCAT('Time Taken (seconds): ',
            DATEDIFF(SECOND, @start_time, GETDATE())
        );
    END TRY
    BEGIN CATCH
        PRINT 'ERROR: olist_customers_dataset failed';
        PRINT ERROR_MESSAGE();
    END CATCH;


    /*====================================================================
        2. olist_geolocation_dataset
    ====================================================================*/
    BEGIN TRY
        DECLARE @start_time2 DATETIME = GETDATE();

        PRINT 'Loading: olist_geolocation_dataset';

        TRUNCATE TABLE bronze.olist_geolocation_dataset;

        BULK INSERT bronze.olist_geolocation_dataset
        FROM 'D:\For_Job\Data_Engineering_Project\olis\olist_geolocation_dataset.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            CODEPAGE = '65001',
            TABLOCK
        );

        PRINT 'SUCCESS: olist_geolocation_dataset loaded';

        PRINT CONCAT('Time Taken (seconds): ',
            DATEDIFF(SECOND, @start_time2, GETDATE())
        );
    END TRY
    BEGIN CATCH
        PRINT 'ERROR: olist_geolocation_dataset failed';
        PRINT ERROR_MESSAGE();
    END CATCH;


    /*====================================================================
        3. olist_order_items_dataset
    ====================================================================*/
    BEGIN TRY
        DECLARE @start_time3 DATETIME = GETDATE();

        PRINT 'Loading: olist_order_items_dataset';

        TRUNCATE TABLE bronze.olist_order_items_dataset;

        BULK INSERT bronze.olist_order_items_dataset
        FROM 'D:\For_Job\Data_Engineering_Project\olis\olist_order_items_dataset.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            CODEPAGE = '65001',
            TABLOCK
        );

        PRINT 'SUCCESS: olist_order_items_dataset loaded';

        PRINT CONCAT('Time Taken (seconds): ',
            DATEDIFF(SECOND, @start_time3, GETDATE())
        );
    END TRY
    BEGIN CATCH
        PRINT 'ERROR: olist_order_items_dataset failed';
        PRINT ERROR_MESSAGE();
    END CATCH;


    /*====================================================================
        4. olist_order_payments_dataset
    ====================================================================*/
    BEGIN TRY
        DECLARE @start_time4 DATETIME = GETDATE();

        PRINT 'Loading: olist_order_payments_dataset';

        TRUNCATE TABLE bronze.olist_order_payments_dataset;

        BULK INSERT bronze.olist_order_payments_dataset
        FROM 'D:\For_Job\Data_Engineering_Project\olis\olist_order_payments_dataset.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            CODEPAGE = '65001',
            TABLOCK
        );

        PRINT 'SUCCESS: olist_order_payments_dataset loaded';

        PRINT CONCAT('Time Taken (seconds): ',
            DATEDIFF(SECOND, @start_time4, GETDATE())
        );
    END TRY
    BEGIN CATCH
        PRINT 'ERROR: olist_order_payments_dataset failed';
        PRINT ERROR_MESSAGE();
    END CATCH;


    /*====================================================================
        5. olist_order_reviews_dataset
    ====================================================================*/
    BEGIN TRY
        DECLARE @start_time5 DATETIME = GETDATE();

        PRINT 'Loading: olist_order_reviews_dataset';

        TRUNCATE TABLE bronze.olist_order_reviews_dataset;

        BULK INSERT bronze.olist_order_reviews_dataset
        FROM 'D:\For_Job\Data_Engineering_Project\olis\olist_order_reviews_dataset.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            CODEPAGE = '65001',
            TABLOCK
        );

        PRINT 'SUCCESS: olist_order_reviews_dataset loaded';

        PRINT CONCAT('Time Taken (seconds): ',
            DATEDIFF(SECOND, @start_time5, GETDATE())
        );
    END TRY
    BEGIN CATCH
        PRINT 'ERROR: olist_order_reviews_dataset failed';
        PRINT ERROR_MESSAGE();
    END CATCH;


    /*====================================================================
        6. olist_orders_dataset
    ====================================================================*/
    BEGIN TRY
        DECLARE @start_time6 DATETIME = GETDATE();

        PRINT 'Loading: olist_orders_dataset';

        TRUNCATE TABLE bronze.olist_orders_dataset;

        BULK INSERT bronze.olist_orders_dataset
        FROM 'D:\For_Job\Data_Engineering_Project\olis\olist_orders_dataset.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            CODEPAGE = '65001',
            TABLOCK
        );

        PRINT 'SUCCESS: olist_orders_dataset loaded';

        PRINT CONCAT('Time Taken (seconds): ',
            DATEDIFF(SECOND, @start_time6, GETDATE())
        );
    END TRY
    BEGIN CATCH
        PRINT 'ERROR: olist_orders_dataset failed';
        PRINT ERROR_MESSAGE();
    END CATCH;


    /*====================================================================
        7. olist_products_dataset
    ====================================================================*/
    BEGIN TRY
        DECLARE @start_time7 DATETIME = GETDATE();

        PRINT 'Loading: olist_products_dataset';

        TRUNCATE TABLE bronze.olist_products_dataset;

        BULK INSERT bronze.olist_products_dataset
        FROM 'D:\For_Job\Data_Engineering_Project\olis\olist_products_dataset.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            CODEPAGE = '65001',
            TABLOCK
        );

        PRINT 'SUCCESS: olist_products_dataset loaded';

        PRINT CONCAT('Time Taken (seconds): ',
            DATEDIFF(SECOND, @start_time7, GETDATE())
        );
    END TRY
    BEGIN CATCH
        PRINT 'ERROR: olist_products_dataset failed';
        PRINT ERROR_MESSAGE();
    END CATCH;


    /*====================================================================
        8. olist_sellers_dataset
    ====================================================================*/
    BEGIN TRY
        DECLARE @start_time8 DATETIME = GETDATE();

        PRINT 'Loading: olist_sellers_dataset';

        TRUNCATE TABLE bronze.olist_sellers_dataset;

        BULK INSERT bronze.olist_sellers_dataset
        FROM 'D:\For_Job\Data_Engineering_Project\olis\olist_sellers_dataset.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            CODEPAGE = '65001',
            TABLOCK
        );

        PRINT 'SUCCESS: olist_sellers_dataset loaded';

        PRINT CONCAT('Time Taken (seconds): ',
            DATEDIFF(SECOND, @start_time8, GETDATE())
        );
    END TRY
    BEGIN CATCH
        PRINT 'ERROR: olist_sellers_dataset failed';
        PRINT ERROR_MESSAGE();
    END CATCH;


    /*====================================================================
        9. product_category_translation
    ====================================================================*/
    BEGIN TRY
        DECLARE @start_time9 DATETIME = GETDATE();

        PRINT 'Loading: product_category_name_translation';

        TRUNCATE TABLE bronze.product_category_name_translation;

        BULK INSERT bronze.product_category_name_translation
        FROM 'D:\For_Job\Data_Engineering_Project\olis\product_category_name_translation.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            CODEPAGE = '65001',
            TABLOCK
        );

        PRINT 'SUCCESS: product_category_name_translation loaded';

        PRINT CONCAT('Time Taken (seconds): ',
            DATEDIFF(SECOND, @start_time9, GETDATE())
        );
    END TRY
    BEGIN CATCH
        PRINT 'ERROR: product_category_name_translation failed';
        PRINT ERROR_MESSAGE();
    END CATCH;


    ------------------------------------------------------
    -- Total Execution Time
    ------------------------------------------------------
    PRINT '======================================================';
    PRINT '===== BRONZE LAYER LOAD COMPLETED =====';
    PRINT CONCAT(
        'TOTAL TIME (seconds): ',
        DATEDIFF(SECOND, @layer_start_time, GETDATE())
    );
    PRINT '======================================================';

END;
GO
