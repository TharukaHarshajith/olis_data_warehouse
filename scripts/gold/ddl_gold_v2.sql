
CREATE OR ALTER VIEW gold.dim_orders AS
SELECT
    ROW_NUMBER() OVER(
        ORDER BY order_id
    ) AS order_key,

    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date
FROM silver.olist_orders_dataset


    
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
