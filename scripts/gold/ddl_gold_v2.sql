
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

