/*====================================================================================================================
    STORED PROCEDURE : silver.load_silver_layer
    AUTHOR           : Tharuka Harshajith - Data Engineer

    DESCRIPTION      :
        This stored procedure loads and transforms data from the Bronze layer
        into the Silver layer of the Olist Data Warehouse.

        Current Transformation Scope:
        -----------------------------------------------------------------------------------------
        1. Customer dataset cleansing
        2. Geolocation dataset standardization
        3. Text normalization using reusable SQL function
        4. Deduplication using ROW_NUMBER()
        5. Coordinate aggregation using window functions

        TRANSFORMATION FEATURES:
        -----------------------------------------------------------------------------------------
        - Removes unwanted special characters
        - Removes accented characters
        - Standardizes casing and spacing
        - Deduplicates geolocation records
        - Calculates average latitude and longitude values
        - Applies full-load ETL strategy

====================================================================================================================*/


/*====================================================================================================================
    FUNCTION : silver.normalize_text
    DESCRIPTION:
        Reusable utility function used to standardize text fields.

        Transformations Applied:
        -----------------------------------------------------------------------------------------
        - Convert to lowercase
        - Remove leading/trailing spaces
        - Remove accented characters
        - Remove unwanted symbols

====================================================================================================================*/

CREATE OR ALTER FUNCTION silver.normalize_text (
    @text NVARCHAR(255)
)
RETURNS NVARCHAR(255)
AS
BEGIN

    ------------------------------------------------------
    -- Convert to lowercase and remove extra spaces
    ------------------------------------------------------
    SET @text = LOWER(TRIM(@text));

    ------------------------------------------------------
    -- Remove accented characters
    ------------------------------------------------------
    SET @text = TRANSLATE(
        @text,
        'áàãâéêíóôõúç',
        'aaaaeeiooouc'
    );

    ------------------------------------------------------
    -- Remove unwanted special characters
    ------------------------------------------------------
    SET @text = REPLACE(@text, '''', '');
    SET @text = REPLACE(@text, '"', '');
    SET @text = REPLACE(@text, '*', '');
    SET @text = REPLACE(@text, '..', '');

    RETURN @text;

END;
GO



/*====================================================================================================================
    STORED PROCEDURE : silver.load_silver_layer
====================================================================================================================*/

CREATE OR ALTER PROCEDURE silver.load_silver_layer
AS
BEGIN

    SET NOCOUNT ON;

    ------------------------------------------------------
    -- Start Layer Timer
    ------------------------------------------------------
    DECLARE @layer_start_time DATETIME = GETDATE();

    ------------------------------------------------------
    -- Variable to Store Inserted Row Count
    ------------------------------------------------------
    DECLARE @rows_inserted INT;

    PRINT '======================================================';
    PRINT '===== SILVER LAYER LOAD STARTED =====';
    PRINT '======================================================';



    /*====================================================================
        1. LOAD CUSTOMER DATASET
    ====================================================================*/

    BEGIN TRY

        DECLARE @customer_start_time DATETIME = GETDATE();

        PRINT 'Loading: silver.olist_customers_dataset';

        ------------------------------------------------------
        -- Full Load Strategy
        ------------------------------------------------------
        TRUNCATE TABLE silver.olist_customers_dataset;

        ------------------------------------------------------
        -- Insert Transformed Data
        ------------------------------------------------------
        INSERT INTO silver.olist_customers_dataset (

            customer_id,
            customer_unique_id,
            customer_zip_code_prefix,
            customer_city,
            customer_state

        )

        SELECT

            REPLACE(customer_id, '"', '')               AS customer_id,
            REPLACE(customer_unique_id, '"', '')        AS customer_unique_id,
            REPLACE(customer_zip_code_prefix, '"', '')  AS customer_zip_code_prefix,

            silver.normalize_text(customer_city)        AS customer_city,
            TRIM(customer_state)                        AS customer_state

        FROM bronze.olist_customers_dataset;

        ------------------------------------------------------
        -- Capture Affected Rows
        ------------------------------------------------------
        SET @rows_inserted = @@ROWCOUNT;
        ------------------------------------------------------
        -- Success Logging
        ------------------------------------------------------
        PRINT 'SUCCESS: silver.olist_customers_dataset loaded';

        PRINT CONCAT(
            'Rows Inserted: ',
            @rows_inserted
        );
        PRINT CONCAT(
            'Time Taken (seconds): ',
            DATEDIFF(SECOND, @customer_start_time, GETDATE())
        );

    END TRY

    BEGIN CATCH

        PRINT 'ERROR: Failed to load silver.olist_customers_dataset';
        PRINT ERROR_MESSAGE();

    END CATCH;



    /*====================================================================
        2. LOAD GEOLOCATION DATASET
    ====================================================================*/

    BEGIN TRY

        DECLARE @geo_start_time DATETIME = GETDATE();

        PRINT 'Loading: silver.olist_geolocation_dataset';

        ------------------------------------------------------
        -- Full Load Strategy
        ------------------------------------------------------
        TRUNCATE TABLE silver.olist_geolocation_dataset;

        ------------------------------------------------------
        -- Insert Cleansed & Deduplicated Data
        ------------------------------------------------------
        INSERT INTO silver.olist_geolocation_dataset (

            geolocation_zip_code_prefix,
            geolocation_lat,
            geolocation_lng,
            geolocation_city,
            geolocation_state

        )

        SELECT

            silver.normalize_text(geolocation_zip_code_prefix)
                AS geolocation_zip_code_prefix,

            geolocation_lat,
            geolocation_lng,

            silver.normalize_text(geolocation_city)
                AS geolocation_city,

            geolocation_state

        FROM (

            SELECT

                geolocation_zip_code_prefix,

                AVG(geolocation_lat)
                    OVER(PARTITION BY geolocation_zip_code_prefix)
                    AS geolocation_lat,

                AVG(geolocation_lng)
                    OVER(PARTITION BY geolocation_zip_code_prefix)
                    AS geolocation_lng,

                geolocation_city,
                geolocation_state,

                ROW_NUMBER()
                    OVER(
                        PARTITION BY geolocation_zip_code_prefix
                        ORDER BY geolocation_zip_code_prefix
                    ) AS flag

            FROM bronze.olist_geolocation_dataset

        ) t

        WHERE flag = 1;

        ------------------------------------------------------
        -- Capture Affected Rows
        ------------------------------------------------------
        SET @rows_inserted = @@ROWCOUNT;

        ------------------------------------------------------
        -- Success Logging
        ------------------------------------------------------
        PRINT 'SUCCESS: silver.olist_geolocation_dataset loaded';

        PRINT CONCAT(
            'Rows Inserted: ',
            @rows_inserted
        );
        PRINT CONCAT(
            'Time Taken (seconds): ',
            DATEDIFF(SECOND, @geo_start_time, GETDATE())
        );

    END TRY

    BEGIN CATCH

        PRINT 'ERROR: Failed to load silver.olist_geolocation_dataset';
        PRINT ERROR_MESSAGE();

    END CATCH;

       /*====================================================================================================================
            3. LOAD ORDER ITEMS DATASET
            DESCRIPTION:
                Loads and cleanses order item-level transactional data from the Bronze layer.

                TRANSFORMATIONS APPLIED:
                -----------------------------------------------------------------------------------------
                - Removes unwanted double quotes
                - Removes leading/trailing spaces
                - Standardizes key columns
                - Preserves transactional numeric values

        ====================================================================================================================*/

        BEGIN TRY

            ------------------------------------------------------
            -- Start Execution Timer
            ------------------------------------------------------
            DECLARE @order_items_start_time DATETIME = GETDATE();

            PRINT 'Loading: silver.olist_order_items_dataset';

            ------------------------------------------------------
            -- Full Load Strategy
            ------------------------------------------------------
            TRUNCATE TABLE silver.olist_order_items_dataset;

            ------------------------------------------------------
            -- Insert Transformed Data
            ------------------------------------------------------
            INSERT INTO silver.olist_order_items_dataset (

                order_id,
                order_item_id,
                product_id,
                seller_id,
                shipping_limit_date,
                price,
                freight_value

            )

            SELECT

                REPLACE(TRIM(order_id), '"', '')
                    AS order_id,

                order_item_id,

                REPLACE(TRIM(product_id), '"', '')
                    AS product_id,

                REPLACE(TRIM(seller_id), '"', '')
                    AS seller_id,

                shipping_limit_date,

                price,
                freight_value

            FROM bronze.olist_order_items_dataset;

            ------------------------------------------------------
            -- Capture Affected Rows
            ------------------------------------------------------
            SET @rows_inserted = @@ROWCOUNT;

            ------------------------------------------------------
            -- Success Logging
            ------------------------------------------------------
            PRINT 'SUCCESS: silver.olist_order_items_dataset loaded';

            PRINT CONCAT(
                'Rows Inserted: ',
                @rows_inserted
            );
            PRINT CONCAT(
                'Time Taken (seconds): ',
                DATEDIFF(SECOND, @order_items_start_time, GETDATE())
            );

        END TRY

        BEGIN CATCH

            ------------------------------------------------------
            -- Error Logging
            ------------------------------------------------------
            PRINT 'ERROR: Failed to load silver.olist_order_items_dataset';
            PRINT ERROR_MESSAGE();

        END CATCH;



    ------------------------------------------------------
    -- Total Layer Execution Time
    ------------------------------------------------------
    PRINT '======================================================';
    PRINT '===== SILVER LAYER LOAD COMPLETED =====';

    PRINT CONCAT(
        'TOTAL TIME (seconds): ',
        DATEDIFF(SECOND, @layer_start_time, GETDATE())
    );

    PRINT '======================================================';

END;
GO
