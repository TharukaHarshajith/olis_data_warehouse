/*====================================================================
    VIEW : gold.customers
    DESCRIPTION:
        Customer dimension table for analytical reporting.

    FEATURES:
        - Surrogate customer key
        - Customer location enrichment
        - Geolocation integration
        - Deduplicated customer records

====================================================================*/

CREATE OR ALTER VIEW gold.customers AS

SELECT

    ROW_NUMBER() OVER (
        ORDER BY t.customer_unique_id
    ) AS customer_key,

    t.customer_unique_id
        AS customer_id,

    t.city,
    t.customer_state
        AS state,

    t.customer_zip_code_prefix
        AS zip_code,

    t.geolocation_lat
        AS latitude,

    t.geolocation_lng
        AS longitude

FROM (

    SELECT 

        c.customer_unique_id,

        -- Use geolocation city if available
        CASE
            WHEN g.geolocation_city IS NULL
            THEN c.customer_city
            ELSE g.geolocation_city
        END AS city,

        c.customer_state,
        c.customer_zip_code_prefix,

        g.geolocation_lat,
        g.geolocation_lng,

        ROW_NUMBER() OVER (
            PARTITION BY c.customer_unique_id
            ORDER BY c.customer_zip_code_prefix
        ) AS row_num

    FROM silver.olist_customers_dataset c

    LEFT JOIN silver.olist_geolocation_dataset g
        ON c.customer_zip_code_prefix =
           g.geolocation_zip_code_prefix

) t

WHERE row_num = 1;
GO

/*====================================================================
    VIEW : gold.sellers
    DESCRIPTION:
        Seller dimension table for analytical reporting.

    FEATURES:
        - Seller location enrichment
        - Geolocation integration
        - Standardized seller attributes

====================================================================*/

CREATE OR ALTER VIEW gold.sellers AS

SELECT
    
    ROW_NUMBER() OVER (
        ORDER BY s.seller_id
    ) AS seller_key,

    s.seller_id,

    -- Use geolocation city if available
    CASE
        WHEN g.geolocation_city IS NULL
        THEN s.seller_city
        ELSE g.geolocation_city
    END AS city,

    s.seller_state
        AS state,

    s.seller_zip_code_prefix
        AS zip_code,

    g.geolocation_lat
        AS latitude,

    g.geolocation_lng
        AS longitude

FROM silver.olist_sellers_dataset s

LEFT JOIN silver.olist_geolocation_dataset g
    ON s.seller_zip_code_prefix =
       g.geolocation_zip_code_prefix;
GO

/*====================================================================
    VIEW : gold.products
    DESCRIPTION:
        Product dimension table for analytical reporting.

    FEATURES:
        - Surrogate product key
        - Product category translation
        - Product physical attributes
        - Product metadata enrichment

====================================================================*/

CREATE OR ALTER VIEW gold.products AS

SELECT 

    ROW_NUMBER() OVER (
        ORDER BY p.product_id
    ) AS product_key,

    p.product_id,

    -- Translate product category if available
    CASE

        WHEN t.product_category_name IS NULL
             AND p.product_category_name = 'n/a'

        THEN p.product_category_name

        WHEN t.product_category_name IS NULL

        THEN CONCAT(
                p.product_category_name,
                ' (Translate)'
             )

        ELSE t.product_category_name_english

    END AS product_category,

    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm,

    p.product_name_lenght,
    p.product_description_lenght,
    p.product_photos_qty

FROM silver.olist_products_dataset p

LEFT JOIN silver.product_category_name_translation t
    ON p.product_category_name =
       t.product_category_name;
GO

/*====================================================================
    VIEW : gold.payments
    DESCRIPTION:
        Aggregated payment summary table at order level.

    FEATURES:
        - One row per order
        - Payment method aggregation
        - Payment amount aggregation
        - Installment aggregation
        - ML-ready payment flags

====================================================================*/

CREATE OR ALTER VIEW gold.payments AS

WITH cte_payment_data AS (

    SELECT

        ROW_NUMBER() OVER (
            ORDER BY order_id
        ) AS payment_key,

        order_id,

        ------------------------------------------------------
        -- Credit Card Metrics
        ------------------------------------------------------
        SUM(used_credit_card)
            AS credit_card_payment_count,

        SUM(credit_card_payment)
            AS credit_card_payment,

        SUM(credit_card_payment_installments)
            AS credit_card_payment_installments,


        ------------------------------------------------------
        -- Debit Card Metrics
        ------------------------------------------------------
        SUM(used_debit_card)
            AS debit_card_payment_count,

        SUM(debit_card_payment)
            AS debit_card_payment,

        SUM(debit_card_payment_installments)
            AS debit_card_payment_installments,


        ------------------------------------------------------
        -- Boleto Metrics
        ------------------------------------------------------
        SUM(used_boleto)
            AS boleto_payment_count,

        SUM(boleto_payment)
            AS boleto_payment,

        SUM(boleto_payment_installments)
            AS boleto_payment_installments,


        ------------------------------------------------------
        -- Voucher Metrics
        ------------------------------------------------------
        SUM(used_voucher)
            AS voucher_payment_count,

        SUM(voucher_payment)
            AS voucher_payment,

        SUM(voucher_payment_installments)
            AS voucher_payment_installments,


        ------------------------------------------------------
        -- Undefined Payment Metrics
        ------------------------------------------------------
        SUM(not_defined_used_payment)
            AS not_defined_payment_count,

        SUM(not_defined_payment)
            AS not_defined_payment,

        SUM(not_defined_payment_installments)
            AS not_defined_payment_installments

    FROM (

        SELECT 

            order_id,

            ------------------------------------------------------
            -- Credit Card
            ------------------------------------------------------
            CASE
                WHEN payment_type = 'credit_card'
                THEN 1
                ELSE 0
            END AS used_credit_card,

            CASE
                WHEN payment_type = 'credit_card'
                THEN payment_value
                ELSE 0
            END AS credit_card_payment,

            CASE
                WHEN payment_type = 'credit_card'
                THEN payment_installments
                ELSE 0
            END AS credit_card_payment_installments,


            ------------------------------------------------------
            -- Debit Card
            ------------------------------------------------------
            CASE
                WHEN payment_type = 'debit_card'
                THEN 1
                ELSE 0
            END AS used_debit_card,

            CASE
                WHEN payment_type = 'debit_card'
                THEN payment_value
                ELSE 0
            END AS debit_card_payment,

            CASE
                WHEN payment_type = 'debit_card'
                THEN payment_installments
                ELSE 0
            END AS debit_card_payment_installments,


            ------------------------------------------------------
            -- Boleto
            ------------------------------------------------------
            CASE
                WHEN payment_type = 'boleto'
                THEN 1
                ELSE 0
            END AS used_boleto,

            CASE
                WHEN payment_type = 'boleto'
                THEN payment_value
                ELSE 0
            END AS boleto_payment,

            CASE
                WHEN payment_type = 'boleto'
                THEN payment_installments
                ELSE 0
            END AS boleto_payment_installments,


            ------------------------------------------------------
            -- Voucher
            ------------------------------------------------------
            CASE
                WHEN payment_type = 'voucher'
                THEN 1
                ELSE 0
            END AS used_voucher,

            CASE
                WHEN payment_type = 'voucher'
                THEN payment_value
                ELSE 0
            END AS voucher_payment,

            CASE
                WHEN payment_type = 'voucher'
                THEN payment_installments
                ELSE 0
            END AS voucher_payment_installments,


            ------------------------------------------------------
            -- Not Defined
            ------------------------------------------------------
            CASE
                WHEN payment_type = 'not_defined'
                THEN 1
                ELSE 0
            END AS not_defined_used_payment,

            CASE
                WHEN payment_type = 'not_defined'
                THEN payment_value
                ELSE 0
            END AS not_defined_payment,

            CASE
                WHEN payment_type = 'not_defined'
                THEN payment_installments
                ELSE 0
            END AS not_defined_payment_installments

        FROM silver.olist_order_payments_dataset

    ) t

    GROUP BY order_id

)

SELECT
    *
FROM cte_payment_data;
GO

/*====================================================================
    VIEW : gold.fact_orders
    DESCRIPTION:
        Order item-level fact table for analytical reporting.

    GRAIN:
        One row per order item.

    FEATURES:
        - Customer integration
        - Product integration
        - Seller integration
        - Order lifecycle timestamps
        - Delivery analytics
        - Data quality monitoring

====================================================================*/

CREATE OR ALTER VIEW gold.fact_orders AS

WITH cte_orders_dataset AS (

    SELECT

        o.order_id,

        c.customer_unique_id,

        o.order_status,

        o.order_purchase_timestamp,
        o.order_approved_at,
        o.order_delivered_carrier_date,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,

        o.dq_invalid_approval_timestamp_flag,
        o.dq_invalid_carrier_timestamp_flag,
        o.dq_invalid_customer_delivery_timestamp_flag,
        o.dq_invalid_estimated_delivery_timestamp_flag

    FROM silver.olist_orders_dataset o

    LEFT JOIN silver.olist_customers_dataset c
        ON o.customer_id = c.customer_id

)

SELECT

    ------------------------------------------------------
    -- Order Information
    ------------------------------------------------------
    i.order_id,

    o.customer_unique_id
        AS customer_id,

    i.product_id,
    i.seller_id,

    o.order_status,


    ------------------------------------------------------
    -- Financial Metrics
    ------------------------------------------------------
    i.price,
    i.freight_value AS shipping_cost,


    ------------------------------------------------------
    -- Shipping & Delivery Dates
    ------------------------------------------------------
    i.shipping_limit_date,

    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,


    ------------------------------------------------------
    -- Data Quality Flags
    ------------------------------------------------------
    o.dq_invalid_approval_timestamp_flag,
    o.dq_invalid_carrier_timestamp_flag,
    o.dq_invalid_customer_delivery_timestamp_flag,
    o.dq_invalid_estimated_delivery_timestamp_flag

FROM silver.olist_order_items_dataset i

LEFT JOIN cte_orders_dataset o
    ON i.order_id = o.order_id;

GO
