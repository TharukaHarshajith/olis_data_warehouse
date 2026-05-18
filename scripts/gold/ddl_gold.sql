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
