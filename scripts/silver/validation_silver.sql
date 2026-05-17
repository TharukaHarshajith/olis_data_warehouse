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

/*####################################################################################################################
                                         ORDER ITEMS DATASET VALIDATION
####################################################################################################################*/


/*====================================================================================================================
    TABLE : silver.olist_order_items_dataset
    DESCRIPTION:
        Validate order item-level transactional data quality.

    VALIDATION SCOPE:
        -----------------------------------------------------------------------------------------
        1. Data preview
        2. Duplicate composite key validation
        3. NULL value validation
        4. Date validation
        5. Numeric validation
        6. Final data inspection

====================================================================================================================*/


/*====================================================================================================================
    1. DATA PREVIEW
    DESCRIPTION:
        Preview sample records from the order items dataset.
====================================================================================================================*/

SELECT TOP 100
    *
FROM silver.olist_order_items_dataset;
GO


/*====================================================================================================================
    2. RAW DATA CLEANING VALIDATION
    DESCRIPTION:
        Verifies unwanted quotation marks were removed during transformation.

        EXPECTED RESULT:
            No rows returned
====================================================================================================================*/

SELECT
    *
FROM silver.olist_order_items_dataset
WHERE order_id = '"73a15e8fc5de8485d1f16639bc66a273"';
GO


/*====================================================================================================================
    3. DUPLICATE KEY VALIDATION
    DESCRIPTION:
        Checks for duplicate composite keys.

        BUSINESS KEY:
            (order_id, order_item_id)

        EXPECTED RESULT:
            No rows returned
====================================================================================================================*/

SELECT
    order_id,
    order_item_id,
    COUNT(*) AS record_count
FROM silver.olist_order_items_dataset
GROUP BY
    order_id,
    order_item_id
HAVING COUNT(*) > 1;
GO


/*====================================================================================================================
    4. NULL VALUE VALIDATION
    DESCRIPTION:
        Checks for NULL values in mandatory business columns.

        EXPECTED RESULT:
            No rows returned
====================================================================================================================*/


-- order_id

SELECT
    *
FROM silver.olist_order_items_dataset
WHERE order_id IS NULL;
GO


-- order_item_id

SELECT
    *
FROM silver.olist_order_items_dataset
WHERE order_item_id IS NULL;
GO


-- product_id

SELECT
    *
FROM silver.olist_order_items_dataset
WHERE product_id IS NULL;
GO


-- seller_id

SELECT
    *
FROM silver.olist_order_items_dataset
WHERE seller_id IS NULL;
GO


-- shipping_limit_date

SELECT
    *
FROM silver.olist_order_items_dataset
WHERE shipping_limit_date IS NULL;
GO


-- price

SELECT
    *
FROM silver.olist_order_items_dataset
WHERE price IS NULL;
GO


-- freight_value

SELECT
    *
FROM silver.olist_order_items_dataset
WHERE freight_value IS NULL;
GO


/*====================================================================================================================
    5. DATE VALIDATION
    DESCRIPTION:
        Checks for invalid shipping dates.

        BUSINESS RULES:
            - Date should not be in the future
            - Date should not be earlier than 2016

        EXPECTED RESULT:
            No rows returned
====================================================================================================================*/

SELECT
    *
FROM silver.olist_order_items_dataset
WHERE shipping_limit_date > GETDATE()
    OR YEAR(shipping_limit_date) < 2016;
GO


/*====================================================================================================================
    6. NUMERIC VALIDATION
    DESCRIPTION:
        Checks for invalid negative monetary values.

        EXPECTED RESULT:
            No rows returned
====================================================================================================================*/


-- Negative product price

SELECT
    *
FROM silver.olist_order_items_dataset
WHERE price < 0;
GO


-- Negative freight value

SELECT
    *
FROM silver.olist_order_items_dataset
WHERE freight_value < 0;
GO


/*====================================================================================================================
    7. FINAL DATA INSPECTION
    DESCRIPTION:
        Final verification of transformed dataset.
====================================================================================================================*/

SELECT
    *
FROM silver.olist_order_items_dataset;
GO

/*####################################################################################################################
                                        ORDER PAYMENTS DATASET VALIDATION
####################################################################################################################*/


/*====================================================================================================================
    TABLE : silver.olist_order_payments_dataset
    DESCRIPTION:
        Validate payment transaction data quality and business consistency.

    VALIDATION SCOPE:
        -----------------------------------------------------------------------------------------
        1. Data preview
        2. Composite key duplicate validation
        3. Order-level payment analysis
        4. Low cardinality analysis
        5. Numeric validation
        6. Final data inspection

====================================================================================================================*/


/*====================================================================================================================
    1. DATA PREVIEW
    DESCRIPTION:
        Preview payment records for a specific order.

====================================================================================================================*/

SELECT
    *
FROM silver.olist_order_payments_dataset
WHERE order_id = 'f1cefe8e64d1771be13b8fd8360385e3';
GO


/*====================================================================================================================
    2. DUPLICATE COMPOSITE KEY VALIDATION
    DESCRIPTION:
        Checks for duplicate payment sequence records.

        BUSINESS KEY:
            (order_id, payment_sequential)

        EXPECTED RESULT:
            No rows returned
====================================================================================================================*/

SELECT
    order_id,
    payment_sequential,
    COUNT(*) AS record_count
FROM silver.olist_order_payments_dataset
GROUP BY
    order_id,
    payment_sequential
HAVING COUNT(*) > 1;
GO


/*====================================================================================================================
    3. ORDER-LEVEL PAYMENT ANALYSIS
    DESCRIPTION:
        Identifies orders with multiple payment records.

        NOTE:
            Multiple rows may exist for installment or split payments.

====================================================================================================================*/

SELECT
    order_id,
    COUNT(*) AS payment_record_count
FROM silver.olist_order_payments_dataset
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY payment_record_count DESC;
GO


/*====================================================================================================================
    4. LOW CARDINALITY ANALYSIS
    DESCRIPTION:
        Reviews distinct payment types.

        PURPOSE:
            - Detect unexpected categories
            - Detect spelling inconsistencies
            - Validate payment method domain
====================================================================================================================*/

SELECT DISTINCT
    payment_type
FROM silver.olist_order_payments_dataset
ORDER BY payment_type;
GO


/*====================================================================================================================
    5. NUMERIC VALIDATION
    DESCRIPTION:
        Checks for invalid negative payment values.

        BUSINESS RULES:
            - payment_installments >= 0
            - payment_value >= 0

        EXPECTED RESULT:
            No rows returned
====================================================================================================================*/

SELECT
    *
FROM silver.olist_order_payments_dataset
WHERE payment_installments < 0
    OR payment_value < 0;
GO


/*====================================================================================================================
    6. FINAL DATA INSPECTION
    DESCRIPTION:
        Final verification of transformed payment dataset.
====================================================================================================================*/

SELECT
    *
FROM silver.olist_order_payments_dataset;
GO

/*####################################################################################################################
                                         ORDER REVIEWS DATASET VALIDATION
####################################################################################################################*/


/*====================================================================================================================
    TABLE : silver.olist_order_reviews_dataset
    DESCRIPTION:
        Validate customer review dataset quality and review-related business rules.

    VALIDATION SCOPE:
        -----------------------------------------------------------------------------------------
        1. Data preview
        2. Duplicate key validation
        3. Low cardinality analysis
        4. Final review data inspection

====================================================================================================================*/


/*====================================================================================================================
    1. DATA PREVIEW
    DESCRIPTION:
        Preview a specific review record for manual validation.
====================================================================================================================*/

SELECT
    *
FROM silver.olist_order_reviews_dataset
WHERE review_id = '466783cc2c97a17f9753dca6a1d24b4a';
GO


/*====================================================================================================================
    2. DUPLICATE KEY VALIDATION
    DESCRIPTION:
        Checks for duplicate review identifiers.

        BUSINESS KEY:
            review_id

        EXPECTED RESULT:
            No rows returned
====================================================================================================================*/

SELECT
    review_id,
    COUNT(*) AS record_count
FROM silver.olist_order_reviews_dataset
GROUP BY review_id
HAVING COUNT(*) > 1;
GO


/*====================================================================================================================
    3. LOW CARDINALITY ANALYSIS
    DESCRIPTION:
        Reviews distinct review titles.

        PURPOSE:
            - Detect unexpected values
            - Detect formatting inconsistencies
            - Analyze review title distribution
====================================================================================================================*/

SELECT DISTINCT
    review_comment_title
FROM silver.olist_order_reviews_dataset
ORDER BY review_comment_title;
GO


/*====================================================================================================================
    4. FINAL DATA INSPECTION
    DESCRIPTION:
        Final verification of transformed review dataset.
====================================================================================================================*/

SELECT
    *
FROM silver.olist_order_reviews_dataset;
GO

/*####################################################################################################################
                                            ORDERS DATASET VALIDATION
####################################################################################################################*/


/*====================================================================
    1. DATA PREVIEW
====================================================================*/

SELECT TOP 100
    *
FROM silver.olist_orders_dataset;
GO


/*====================================================================
    2. DUPLICATE CHECK
====================================================================*/

SELECT
    order_id,
    COUNT(*) AS record_count
FROM silver.olist_orders_dataset
GROUP BY order_id
HAVING COUNT(*) > 1;
GO


/*====================================================================
    3. NULL CHECKS
====================================================================*/

SELECT *
FROM silver.olist_orders_dataset
WHERE order_id IS NULL;
GO

SELECT *
FROM silver.olist_orders_dataset
WHERE customer_id IS NULL;
GO

SELECT *
FROM silver.olist_orders_dataset
WHERE order_status IS NULL;
GO

SELECT *
FROM silver.olist_orders_dataset
WHERE order_purchase_timestamp IS NULL;
GO


/*====================================================================
    4. WHITESPACE CHECKS
====================================================================*/

SELECT *
FROM silver.olist_orders_dataset
WHERE order_id <> TRIM(order_id);
GO

SELECT *
FROM silver.olist_orders_dataset
WHERE customer_id <> TRIM(customer_id);
GO

SELECT *
FROM silver.olist_orders_dataset
WHERE order_status <> TRIM(order_status);
GO


/*====================================================================
    5. INVALID TIMESTAMP SEQUENCE CHECKS
====================================================================*/

-- Approval before purchase

SELECT *
FROM silver.olist_orders_dataset
WHERE order_approved_at < order_purchase_timestamp;
GO


-- Carrier delivery before approval

SELECT *
FROM silver.olist_orders_dataset
WHERE order_delivered_carrier_date < order_approved_at;
GO


-- Customer delivery before carrier delivery

SELECT *
FROM silver.olist_orders_dataset
WHERE order_delivered_customer_date < order_delivered_carrier_date;
GO


-- Estimated delivery before purchase

SELECT *
FROM silver.olist_orders_dataset
WHERE order_estimated_delivery_date < order_purchase_timestamp;
GO


/*====================================================================
    6. DATA QUALITY FLAG CHECKS
====================================================================*/

SELECT *
FROM silver.olist_orders_dataset
WHERE dq_invalid_approval_timestamp_flag = 1;
GO

SELECT *
FROM silver.olist_orders_dataset
WHERE dq_invalid_carrier_timestamp_flag = 1;
GO

SELECT *
FROM silver.olist_orders_dataset
WHERE dq_invalid_customer_delivery_timestamp_flag = 1;
GO

SELECT *
FROM silver.olist_orders_dataset
WHERE dq_invalid_estimated_delivery_timestamp_flag = 1;
GO


/*====================================================================
    7. ORDER STATUS ANALYSIS
====================================================================*/

SELECT DISTINCT
    order_status
FROM silver.olist_orders_dataset
ORDER BY order_status;
GO


/*====================================================================
    8. FINAL DATA CHECK
====================================================================*/

SELECT *
FROM silver.olist_orders_dataset;
GO
