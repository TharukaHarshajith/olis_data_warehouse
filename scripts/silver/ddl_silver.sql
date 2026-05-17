/*====================================================================================================================
    Project      : Olist Data Warehouse
    Layer        : Silver Layer
    Author       : Tharuka Harshajith - Data Engineer

    Description  :
        This script creates all cleansed and standardized tables required for the
        Silver layer of the Olist Data Warehouse.

        The Silver layer is responsible for:
        -----------------------------------------------------------------------------------------
        - Data cleansing
        - Data standardization
        - Type correction
        - Null handling
        - Deduplication
        - Preparing structured data for business transformation

        Data in this layer is transformed from the Bronze layer and optimized
        for downstream analytical processing in the Gold layer.

    Design Standards :
        -----------------------------------------------------------------------------------------
        - Uses improved datatypes compared to Bronze
        - Adds audit column: dwh_create_date
        - Uses DATETIME2 for higher precision
        - Naming convention:
              silver.<table_name>

====================================================================================================================*/

USE OlistDWH;
GO


/*====================================================================================================================
    TABLE: silver.olist_customers_dataset
    DESCRIPTION:
        Stores cleansed customer master data.
====================================================================================================================*/

IF OBJECT_ID('silver.olist_customers_dataset', 'U') IS NOT NULL
    DROP TABLE silver.olist_customers_dataset;
GO

CREATE TABLE silver.olist_customers_dataset (

    customer_id                NVARCHAR(50),
    customer_unique_id         NVARCHAR(50),
    customer_zip_code_prefix   NVARCHAR(20),
    customer_city              NVARCHAR(100),
    customer_state             NVARCHAR(10),

    dwh_create_date            DATETIME2 DEFAULT GETDATE()

);
GO


/*====================================================================================================================
    TABLE: silver.olist_orders_dataset
    DESCRIPTION:
        Stores cleansed order transaction and delivery lifecycle information.
====================================================================================================================*/

IF OBJECT_ID('silver.olist_orders_dataset', 'U') IS NOT NULL
    DROP TABLE silver.olist_orders_dataset;
GO

CREATE TABLE silver.olist_orders_dataset (

    order_id                         NVARCHAR(50),
    customer_id                      NVARCHAR(50),
    order_status                     NVARCHAR(30),

    order_purchase_timestamp         DATETIME2,
    order_approved_at                DATETIME2,
    order_delivered_carrier_date     DATETIME2,
    order_delivered_customer_date    DATETIME2,
    order_estimated_delivery_date    DATETIME2,

    dq_invalid_approval_timestamp_flag            BIT,
    dq_invalid_carrier_timestamp_flag             BIT,
    dq_invalid_customer_delivery_timestamp_flag   BIT,
    dq_invalid_estimated_delivery_timestamp_flag  BIT,


    dwh_create_date                  DATETIME2 DEFAULT GETDATE()

);
GO


/*====================================================================================================================
    TABLE: silver.olist_order_items_dataset
    DESCRIPTION:
        Stores cleansed order item-level transaction details.
====================================================================================================================*/

IF OBJECT_ID('silver.olist_order_items_dataset', 'U') IS NOT NULL
    DROP TABLE silver.olist_order_items_dataset;
GO

CREATE TABLE silver.olist_order_items_dataset (

    order_id               NVARCHAR(50),
    order_item_id          INT,
    product_id             NVARCHAR(50),
    seller_id              NVARCHAR(50),

    shipping_limit_date    DATETIME2,

    price                  DECIMAL(10,2),
    freight_value          DECIMAL(10,2),

    dwh_create_date        DATETIME2 DEFAULT GETDATE()

);
GO


/*====================================================================================================================
    TABLE: silver.olist_order_payments_dataset
    DESCRIPTION:
        Stores cleansed payment transaction details.
====================================================================================================================*/

IF OBJECT_ID('silver.olist_order_payments_dataset', 'U') IS NOT NULL
    DROP TABLE silver.olist_order_payments_dataset;
GO

CREATE TABLE silver.olist_order_payments_dataset (

    order_id                 NVARCHAR(50),
    payment_sequential       INT,
    payment_type             NVARCHAR(30),
    payment_installments     INT,

    payment_value            DECIMAL(10,2),

    dwh_create_date          DATETIME2 DEFAULT GETDATE()

);
GO


/*====================================================================================================================
    TABLE: silver.olist_order_reviews_dataset
    DESCRIPTION:
        Stores customer review and feedback information.
====================================================================================================================*/

IF OBJECT_ID('silver.olist_order_reviews_dataset', 'U') IS NOT NULL
    DROP TABLE silver.olist_order_reviews_dataset;
GO

CREATE TABLE silver.olist_order_reviews_dataset (

    review_id                   NVARCHAR(50),
    order_id                    NVARCHAR(50),

    review_score                INT,

    review_comment_title        NVARCHAR(MAX),
    review_comment_message      NVARCHAR(MAX),

    review_creation_date        DATETIME2,
    review_answer_timestamp     DATETIME2,

    dwh_create_date             DATETIME2 DEFAULT GETDATE()

);
GO


/*====================================================================================================================
    TABLE: silver.olist_products_dataset
    DESCRIPTION:
        Stores cleansed product catalog and product dimension information.
====================================================================================================================*/

IF OBJECT_ID('silver.olist_products_dataset', 'U') IS NOT NULL
    DROP TABLE silver.olist_products_dataset;
GO

CREATE TABLE silver.olist_products_dataset (

    product_id                     NVARCHAR(50),
    product_category_name          NVARCHAR(100),

    product_name_lenght            INT,
    product_description_lenght     INT,
    product_photos_qty             INT,

    product_weight_g               INT,
    product_length_cm              INT,
    product_height_cm              INT,
    product_width_cm               INT,

    dwh_create_date                DATETIME2 DEFAULT GETDATE()

);
GO


/*====================================================================================================================
    TABLE: silver.olist_geolocation_dataset
    DESCRIPTION:
        Stores cleansed geographical mapping information.
====================================================================================================================*/

IF OBJECT_ID('silver.olist_geolocation_dataset', 'U') IS NOT NULL
    DROP TABLE silver.olist_geolocation_dataset;
GO

CREATE TABLE silver.olist_geolocation_dataset (

    geolocation_zip_code_prefix    NVARCHAR(20),

    geolocation_lat                DECIMAL(10,6),
    geolocation_lng                DECIMAL(10,6),

    geolocation_city               NVARCHAR(100),
    geolocation_state              NVARCHAR(10),

    dwh_create_date                DATETIME2 DEFAULT GETDATE()

);
GO


/*====================================================================================================================
    TABLE: silver.olist_sellers_dataset
    DESCRIPTION:
        Stores cleansed seller master data.
====================================================================================================================*/

IF OBJECT_ID('silver.olist_sellers_dataset', 'U') IS NOT NULL
    DROP TABLE silver.olist_sellers_dataset;
GO

CREATE TABLE silver.olist_sellers_dataset (

    seller_id                  NVARCHAR(50),
    seller_zip_code_prefix     NVARCHAR(20),

    seller_city                NVARCHAR(100),
    seller_state               NVARCHAR(10),

    dwh_create_date            DATETIME2 DEFAULT GETDATE()

);
GO


/*====================================================================================================================
    TABLE: silver.product_category_name_translation
    DESCRIPTION:
        Stores translated product category names from Portuguese to English.
====================================================================================================================*/

IF OBJECT_ID('silver.product_category_name_translation', 'U') IS NOT NULL
    DROP TABLE silver.product_category_name_translation;
GO

CREATE TABLE silver.product_category_name_translation (

    product_category_name              NVARCHAR(100),
    product_category_name_english      NVARCHAR(100),

    dwh_create_date                    DATETIME2 DEFAULT GETDATE()

);
GO


/*====================================================================================================================
    VALIDATION CHECK
====================================================================================================================*/

SELECT
    TABLE_SCHEMA,
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'silver'
ORDER BY TABLE_NAME;
GO
