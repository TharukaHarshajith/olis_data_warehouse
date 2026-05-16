/*====================================================================================================================
    DATA QUALITY CHECKS
    LAYER : Silver Layer
    AUTHOR: Tharuka Harshajith - Data Engineer

    DESCRIPTION :
        This script performs data quality validation checks on Silver layer tables
        within the Olist Data Warehouse.

        Validation Categories:
        -----------------------------------------------------------------------------------------
        1. Data preview
        2. Primary key validation
        3. Duplicate detection
        4. NULL value validation
        5. Whitespace validation
        6. Low cardinality analysis
        7. Data profiling
        8. Business rule validation

====================================================================================================================*/



/*####################################################################################################################
                                            CUSTOMER DATASET VALIDATION
####################################################################################################################*/


/*====================================================================================================================
    TABLE : silver.olist_customers_dataset
    DESCRIPTION:
        Validate customer master dataset quality.
====================================================================================================================*/


/*====================================================================================================================
    1. DATA PREVIEW
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
        Detects leading/trailing spaces in text columns.

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





/*####################################################################################################################
                                          GEOLOCATION DATASET VALIDATION
####################################################################################################################*/


/*====================================================================================================================
    TABLE : silver.olist_geolocation_dataset
    DESCRIPTION:
        Validate geolocation dataset quality and standardization.
====================================================================================================================*/


/*====================================================================================================================
    1. DATA PREVIEW
====================================================================================================================*/

SELECT TOP 100
    *
FROM silver.olist_geolocation_dataset;
GO


/*====================================================================================================================
    2. DUPLICATE VALIDATION
    DESCRIPTION:
        Checks for duplicate ZIP code prefixes.

        EXPECTED RESULT:
            No rows returned
====================================================================================================================*/

SELECT
    geolocation_zip_code_prefix,
    COUNT(*) AS record_count
FROM silver.olist_geolocation_dataset
GROUP BY geolocation_zip_code_prefix
HAVING COUNT(*) > 1;
GO


/*====================================================================================================================
    3. NULL VALUE VALIDATION
    DESCRIPTION:
        Checks for NULL geographic coordinates.

        EXPECTED RESULT:
            No rows returned
====================================================================================================================*/


-- NULL latitude values

SELECT
    *
FROM silver.olist_geolocation_dataset
WHERE geolocation_lat IS NULL;
GO


-- NULL longitude values

SELECT
    *
FROM silver.olist_geolocation_dataset
WHERE geolocation_lng IS NULL;
GO


/*====================================================================================================================
    4. WHITESPACE VALIDATION
    DESCRIPTION:
        Detects leading/trailing spaces in city names.

        EXPECTED RESULT:
            No rows returned
====================================================================================================================*/

SELECT
    *
FROM silver.olist_geolocation_dataset
WHERE geolocation_city <> TRIM(geolocation_city);
GO


/*====================================================================================================================
    5. LOW CARDINALITY ANALYSIS
    DESCRIPTION:
        Reviews distinct categorical values.

        PURPOSE:
            - Detect spelling inconsistencies
            - Detect formatting issues
            - Detect unexpected values
====================================================================================================================*/


-- Distinct Cities

SELECT DISTINCT
    geolocation_city
FROM silver.olist_geolocation_dataset
ORDER BY geolocation_city;
GO


-- Distinct States

SELECT DISTINCT
    geolocation_state
FROM silver.olist_geolocation_dataset
ORDER BY geolocation_state;
GO


/*====================================================================================================================
    6. BUSINESS RULE VALIDATION
    DESCRIPTION:
        Validates state code length.

        BUSINESS RULE:
            Brazilian state abbreviations must contain exactly 2 characters.

        EXPECTED RESULT:
            No rows returned
====================================================================================================================*/

SELECT
    *
FROM silver.olist_geolocation_dataset
WHERE LEN(geolocation_state) <> 2;
GO
