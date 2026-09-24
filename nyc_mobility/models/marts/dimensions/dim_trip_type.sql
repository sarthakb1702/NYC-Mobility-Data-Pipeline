{{ config(
    materialized='table',
    schema='MARTS'
) }}

WITH trip_types AS (

    SELECT
        trip_type_id AS trip_type_key,
        trip_type

    FROM {{ ref('stg_green_taxi') }}

    WHERE trip_type_id IS NOT NULL

    GROUP BY
        trip_type_id,
        trip_type
)

SELECT
    trip_type_key,
    trip_type

FROM trip_types

UNION ALL

SELECT
    0 AS trip_type_key,
    'Missing / Unknown' AS trip_type

WHERE NOT EXISTS (
    SELECT 1
    FROM trip_types
    WHERE trip_type_key = 0
)