{{ config(
    materialized='table',
    schema='MARTS'
) }}

WITH payment_types AS (

    SELECT
        payment_type_id AS payment_key,
        payment_type_id,
        payment_type

    FROM {{ ref('stg_yellow_taxi') }}

    WHERE payment_type_id IS NOT NULL

    GROUP BY
        payment_type_id,
        payment_type
)

SELECT
    payment_key,
    payment_type_id,
    payment_type

FROM payment_types

UNION ALL

SELECT
    6 AS payment_key,
    NULL AS payment_type_id,
    'Missing / Unknown' AS payment_type