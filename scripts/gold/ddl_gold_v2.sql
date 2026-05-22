
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
