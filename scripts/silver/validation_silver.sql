/*====================================================================================================================
    DATA QUALITY CHECKS
    TABLE : silver.olist_customers_dataset
    LAYER : Silver Layer

    DESCRIPTION :
        This script performs data quality validation checks on the
        silver.olist_customers_dataset table.

        Validation Categories:
        -----------------------------------------------------------------------------------------
        1. Primary key validation
        2. Duplicate detection
        3. NULL value checks
        4. Whitespace validation
        5. Low cardinality analysis
        6. Data profiling

====================================================================================================================*/


/*====================================================================================================================
    1. DATA PREVIEW
    DESCRIPTION:
        Preview sample records from the Silver customer dataset.
====================================================================================================================*/

SELECT TOP 100
    *
FROM silver.olist_customers_dataset;
GO


/*====================================================================================================================
    2. PRIMARY KEY VALIDATION
    DESCRIPTION:
        Checks for:
            - Duplicate customer_id values
            - NULL customer_id values

        EXPECTED RESULT:
            No rows returned
====================================================================================================================*/

SELECT
    customer_id,
    COUNT(*) AS record_count
FROM silver.olist_customers_dataset
GROUP BY customer_id
HAVING COUNT(*) > 1
    OR customer_id IS NULL;
GO


/*====================================================================================================================
    3. WHITESPACE VALIDATION
    DESCRIPTION:
        Checks for leading or trailing spaces in text-based columns.

        EXPECTED RESULT:
            No rows returned
====================================================================================================================*/


-- customer_id

SELECT
    *
FROM silver.olist_customers_dataset
WHERE customer_id <> TRIM(customer_id);
GO


-- customer_unique_id

SELECT
    *
FROM silver.olist_customers_dataset
WHERE customer_unique_id <> TRIM(customer_unique_id);
GO


-- customer_zip_code_prefix

SELECT
    *
FROM silver.olist_customers_dataset
WHERE customer_zip_code_prefix <> TRIM(customer_zip_code_prefix);
GO


-- customer_city

SELECT
    *
FROM silver.olist_customers_dataset
WHERE customer_city <> TRIM(customer_city);
GO


-- customer_state

SELECT
    *
FROM silver.olist_customers_dataset
WHERE customer_state <> TRIM(customer_state);
GO


/*====================================================================================================================
    4. NULL VALUE VALIDATION
    DESCRIPTION:
        Checks for NULL values in important business columns.

        EXPECTED RESULT:
            No rows returned
====================================================================================================================*/


-- customer_unique_id

SELECT
    *
FROM silver.olist_customers_dataset
WHERE customer_unique_id IS NULL;
GO


-- customer_zip_code_prefix

SELECT
    *
FROM silver.olist_customers_dataset
WHERE customer_zip_code_prefix IS NULL;
GO


-- customer_city

SELECT
    *
FROM silver.olist_customers_dataset
WHERE customer_city IS NULL;
GO


-- customer_state

SELECT
    *
FROM silver.olist_customers_dataset
WHERE customer_state IS NULL;
GO


/*====================================================================================================================
    5. LOW CARDINALITY ANALYSIS
    DESCRIPTION:
        Reviews distinct values for categorical columns.

        PURPOSE:
            - Detect inconsistent values
            - Detect spelling issues
            - Detect unexpected categories
====================================================================================================================*/


-- Distinct Customer Cities

SELECT DISTINCT
    customer_city
FROM silver.olist_customers_dataset
ORDER BY customer_city;
GO


-- Distinct Customer States

SELECT DISTINCT
    customer_state
FROM silver.olist_customers_dataset
ORDER BY customer_state;
GO
