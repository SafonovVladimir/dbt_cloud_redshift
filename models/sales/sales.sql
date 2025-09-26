-- models/sales_transformed.sql

WITH base AS (
    SELECT
        sale_id,
        sale_date,
        customer_id,
        product_id,
        quantity,
        price_per_unit,
        total_amount
    FROM {{ source('redshift_source', 'sales') }} 
),

enriched AS (
    SELECT
        sale_id,
        sale_date,
        customer_id,
        product_id,
        quantity,
        price_per_unit,
        total_amount,
        -- Add a derived column: total_amount_check for validation
        quantity * price_per_unit AS total_amount_check,
        -- Add day of week for analysis
        TO_CHAR(sale_date, 'Day') AS day_of_week,
        -- Add a price category
        CASE
            WHEN price_per_unit < 20 THEN 'Low'
            WHEN price_per_unit BETWEEN 20 AND 50 THEN 'Medium'
            ELSE 'High'
        END AS price_category
    FROM base
)

SELECT * FROM enriched