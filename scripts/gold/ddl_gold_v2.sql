CREATE OR ALTER VIEW gold.dim_customers AS
WITH customer_data AS (
    SELECT
        c.customer_unique_id,
        c.customer_city,
        c.customer_state,
        c.customer_zip_code_prefix,
        g.geolocation_lat,
        g.geolocation_lng,
        ROW_NUMBER() OVER ( PARTITION BY c.customer_unique_id  ORDER BY c.customer_zip_code_prefix) AS row_num
    FROM silver.olist_customers_dataset c
    LEFT JOIN silver.olist_geolocation_dataset g
    ON c.customer_zip_code_prefix = g.geolocation_zip_code_prefix
)

SELECT
    ROW_NUMBER() OVER (ORDER BY customer_unique_id) AS customer_key,
    customer_unique_id,
    customer_city,
    customer_state,
    customer_zip_code_prefix,
    geolocation_lat,
    geolocation_lng
FROM customer_data
WHERE row_num = 1


CREATE OR ALTER VIEW gold.dim_products AS
SELECT
    ROW_NUMBER() OVER (ORDER BY p.product_id) AS product_key,
    p.product_id,
    -- Translate product category if available
    CASE
        WHEN t.product_category_name IS NULL AND p.product_category_name = 'n/a' THEN p.product_category_name
        WHEN t.product_category_name IS NULL THEN CONCAT( p.product_category_name, ' (Translate)' )
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
ON p.product_category_name = t.product_category_name


CREATE OR ALTER VIEW gold.dim_sellers AS
SELECT    
    ROW_NUMBER() OVER (ORDER BY s.seller_id) AS seller_key,
    s.seller_id,
    -- Use geolocation city if available
    CASE
        WHEN g.geolocation_city IS NULL
        THEN s.seller_city
        ELSE g.geolocation_city
    END AS city,
    s.seller_state AS state,
    s.seller_zip_code_prefix AS zip_code,
    g.geolocation_lat AS latitude,
    g.geolocation_lng AS longitude
FROM silver.olist_sellers_dataset s
LEFT JOIN silver.olist_geolocation_dataset g
ON s.seller_zip_code_prefix = g.geolocation_zip_code_prefix;



CREATE OR ALTER VIEW gold.dim_orders AS
SELECT
    ROW_NUMBER() OVER(ORDER BY order_id) AS order_key,
    order_id,
    c.customer_key,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    o.dq_invalid_approval_timestamp_flag,
    o.dq_invalid_carrier_timestamp_flag,
    o.dq_invalid_customer_delivery_timestamp_flag,
    o.dq_invalid_estimated_delivery_timestamp_flag
FROM silver.olist_orders_dataset o
LEFT JOIN silver.olist_customers_dataset sc
ON o.customer_id = sc.customer_id
LEFT JOIN gold.dim_customers c
ON sc.customer_unique_id = c.customer_unique_id

    
CREATE OR ALTER VIEW gold.fact_order_items AS
SELECT
    d.order_key,
    p.product_key,
    s.seller_key,
    oi.price,
    oi.freight_value AS shipping_cost
FROM silver.olist_order_items_dataset oi
LEFT JOIN gold.dim_orders d
ON oi.order_id = d.order_id
LEFT JOIN gold.dim_products p
ON oi.product_id = p.product_id
LEFT JOIN gold.dim_sellers s
ON oi.seller_id = s.seller_id


CREATE OR ALTER VIEW gold.fact_payments AS
SELECT
    d.order_key,
    payment_type,
    payment_installments,
    payment_value
FROM silver.olist_order_payments_dataset p
LEFT JOIN gold.dim_orders d
ON p.order_id = d.order_id

CREATE OR ALTER VIEW gold.fact_reviews AS
SELECT
    d.order_key,
    review_score,
    review_creation_date
FROM silver.olist_order_reviews_dataset r
LEFT JOIN gold.dim_orders d
ON r.order_id = d.order_id


