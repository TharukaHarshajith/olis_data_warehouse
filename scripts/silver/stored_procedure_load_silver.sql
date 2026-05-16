/*====================================================================================================================
    STORED PROCEDURE : silver.load_silver_layer
    AUTHOR           : Tharuka Harshajith - Data Engineer

    DESCRIPTION      :
        This stored procedure loads and transforms data from the Bronze layer
        into the Silver layer of the Olist Data Warehouse.

        Current Transformation Scope:
        -----------------------------------------------------------------------------------------
        1. Cleans customer dataset fields
        2. Removes unwanted double quotes from raw string columns
        3. Standardizes customer-related data before analytical processing

        Future Enhancements:
        -----------------------------------------------------------------------------------------
        - Add transformations for remaining Silver tables
        - Implement deduplication logic
        - Add data quality validations
        - Add NULL handling rules
        - Add logging and execution tracking

    LOAD STRATEGY :
        -----------------------------------------------------------------------------------------
        Source Layer      : Bronze
        Target Layer      : Silver
        Load Type         : Full Load (Truncate & Insert)

====================================================================================================================*/

CREATE OR ALTER PROCEDURE silver.load_silver_layer
AS
BEGIN

    SET NOCOUNT ON;

    ------------------------------------------------------
    -- Start Process Logging
    ------------------------------------------------------
    PRINT '======================================================';
    PRINT '===== SILVER LAYER LOAD STARTED =====';
    PRINT '======================================================';


    /*====================================================================
        TABLE: silver.olist_customers_dataset
        DESCRIPTION:
            Cleans and standardizes customer master data.
    ====================================================================*/

    BEGIN TRY

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

            TRIM(customer_city)                         AS customer_city,
            TRIM(customer_state)                        AS customer_state

        FROM bronze.olist_customers_dataset;

        ------------------------------------------------------
        -- Success Message
        ------------------------------------------------------
        PRINT 'SUCCESS: silver.olist_customers_dataset loaded successfully';

    END TRY

    BEGIN CATCH

        ------------------------------------------------------
        -- Error Handling
        ------------------------------------------------------
        PRINT 'ERROR: Failed to load silver.olist_customers_dataset';
        PRINT ERROR_MESSAGE();

    END CATCH;


    ------------------------------------------------------
    -- End Process Logging
    ------------------------------------------------------
    PRINT '======================================================';
    PRINT '===== SILVER LAYER LOAD COMPLETED =====';
    PRINT '======================================================';

END;
GO
