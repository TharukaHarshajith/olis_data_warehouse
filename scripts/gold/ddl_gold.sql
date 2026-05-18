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
