/*====================================================================================================================
    Project      : Olist Data Warehouse
    Layer        : Bronze Layer
    Author       : Tharuka Harshajith - Data Engineer

    Description  :
        This script creates all raw ingestion tables required for the Bronze layer of the
        Olist Data Warehouse using the Medallion Architecture approach.

        The Bronze layer stores raw source data exactly as received from source systems
        with minimal transformation. These tables act as the landing zone for ingestion
        processes before cleansing and transformation in the Silver layer.

    Design Notes :
        - Uses NVARCHAR for flexible raw data ingestion
        - FLOAT used for monetary values in raw stage
        - DATETIME used for timestamp-based fields
        - Existing tables are dropped before recreation
        - Naming convention follows:
              bronze.<source_table_name>

====================================================================================================================*/

USE OlistDWH;
GO


/*====================================================================================================================
    TABLE: bronze.olist_customers_dataset
    DESCRIPTION:
        Stores customer master information including location details.
====================================================================================================================*/

IF OBJECT_ID('bronze.olist_customers_dataset', 'U') IS NOT NULL
    DROP TABLE bronze.olist_customers_dataset;
GO

CREATE TABLE bronze.olist_customers_dataset (
    customer_id                NVARCHAR(50),
    customer_unique_id         NVARCHAR(50),
    customer_zip_code_prefix   NVARCHAR(50),
    customer_city              NVARCHAR(50),
    customer_state             NVARCHAR(50)
);
GO


/*====================================================================================================================
    TABLE: bronze.olist_orders_dataset
    DESCRIPTION:
        Stores order transaction details and delivery lifecycle timestamps.
====================================================================================================================*/

IF OBJECT_ID('bronze.olist_orders_dataset', 'U') IS NOT NULL
    DROP TABLE bronze.olist_orders_dataset;
GO

CREATE TABLE bronze.olist_orders_dataset (
    order_id                         NVARCHAR(50),
    customer_id                      NVARCHAR(50),
    order_status                     NVARCHAR(50),
    order_purchase_timestamp         DATETIME,
    order_approved_at                DATETIME,
    order_delivered_carrier_date     DATETIME,
    order_delivered_customer_date    DATETIME,
    order_estimated_delivery_date    DATETIME
);
GO


/*====================================================================================================================
    TABLE: bronze.olist_order_items_dataset
    DESCRIPTION:
        Stores item-level order details including product, seller, and shipping information.
====================================================================================================================*/

IF OBJECT_ID('bronze.olist_order_items_dataset', 'U') IS NOT NULL
    DROP TABLE bronze.olist_order_items_dataset;
GO

CREATE TABLE bronze.olist_order_items_dataset (
    order_id               NVARCHAR(50),
    order_item_id          NVARCHAR(50),
    product_id             NVARCHAR(50),
    seller_id              NVARCHAR(50),
    shipping_limit_date    DATETIME,
    price                  FLOAT,
    freight_value          FLOAT
);
GO


/*====================================================================================================================
    TABLE: bronze.olist_order_payments_dataset
    DESCRIPTION:
        Stores payment transaction details for customer orders.
====================================================================================================================*/

IF OBJECT_ID('bronze.olist_order_payments_dataset', 'U') IS NOT NULL
    DROP TABLE bronze.olist_order_payments_dataset;
GO

CREATE TABLE bronze.olist_order_payments_dataset (
    order_id                 NVARCHAR(50),
    payment_sequential       NVARCHAR(50),
    payment_type             NVARCHAR(50),
    payment_installments     INT,
    payment_value            FLOAT
);
GO


/*====================================================================================================================
    TABLE: bronze.olist_order_reviews_dataset
    DESCRIPTION:
        Stores customer review and feedback data related to completed orders.
====================================================================================================================*/

IF OBJECT_ID('bronze.olist_order_reviews_dataset', 'U') IS NOT NULL
    DROP TABLE bronze.olist_order_reviews_dataset;
GO

CREATE TABLE bronze.olist_order_reviews_dataset (
    review_id                  NVARCHAR(50),
    order_id                   NVARCHAR(50),
    review_score               INT,
    review_comment_title       NVARCHAR(100),
    review_comment_message     NVARCHAR(500),
    review_creation_date       DATETIME,
    review_answer_timestamp    DATETIME
);
GO


/*====================================================================================================================
    TABLE: bronze.olist_products_dataset
    DESCRIPTION:
        Stores product catalog information and physical product attributes.
====================================================================================================================*/

IF OBJECT_ID('bronze.olist_products_dataset', 'U') IS NOT NULL
    DROP TABLE bronze.olist_products_dataset;
GO

CREATE TABLE bronze.olist_products_dataset (
    product_id                    NVARCHAR(50),
    product_category_name         NVARCHAR(100),
    product_name_lenght           INT,
    product_description_lenght    INT,
    product_photos_qty            INT,
    product_weight_g              INT,
    product_length_cm             INT,
    product_height_cm             INT,
    product_width_cm              INT
);
GO


/*====================================================================================================================
    TABLE: bronze.olist_geolocation_dataset
    DESCRIPTION:
        Stores geographic mapping data including coordinates and location details.
====================================================================================================================*/

IF OBJECT_ID('bronze.olist_geolocation_dataset', 'U') IS NOT NULL
    DROP TABLE bronze.olist_geolocation_dataset;
GO

CREATE TABLE bronze.olist_geolocation_dataset (
    geolocation_zip_code_prefix    NVARCHAR(50),
    geolocation_lat                FLOAT,
    geolocation_lng                FLOAT,
    geolocation_city               NVARCHAR(50),
    geolocation_state              NVARCHAR(50)
);
GO


/*====================================================================================================================
    TABLE: bronze.olist_sellers_dataset
    DESCRIPTION:
        Stores seller and merchant information including location data.
====================================================================================================================*/

IF OBJECT_ID('bronze.olist_sellers_dataset', 'U') IS NOT NULL
    DROP TABLE bronze.olist_sellers_dataset;
GO

CREATE TABLE bronze.olist_sellers_dataset (
    seller_id                  NVARCHAR(50),
    seller_zip_code_prefix     NVARCHAR(50),
    seller_city                NVARCHAR(50),
    seller_state               NVARCHAR(50)
);
GO


/*====================================================================================================================
    TABLE: bronze.product_category_name_translation
    DESCRIPTION:
        Stores category name translations from Portuguese to English.
====================================================================================================================*/

IF OBJECT_ID('bronze.product_category_name_translation', 'U') IS NOT NULL
    DROP TABLE bronze.product_category_name_translation;
GO

CREATE TABLE bronze.product_category_name_translation (
    product_category_name              NVARCHAR(100),
    product_category_name_english      NVARCHAR(100)
);
GO


/*====================================================================================================================
    VALIDATION CHECK
====================================================================================================================*/

SELECT 
    TABLE_SCHEMA,
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'bronze'
ORDER BY TABLE_NAME;
GO