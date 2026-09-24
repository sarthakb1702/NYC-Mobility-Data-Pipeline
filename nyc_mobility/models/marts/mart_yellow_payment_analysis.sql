{{ config(
    materialized='table',
    schema='MARTS'
) }}

SELECT
    f.payment_key,

    p.payment_type,

    COUNT(*) AS total_trips,

    SUM(f.total_amount) AS total_revenue,

    AVG(f.total_amount) AS avg_trip_amount,

    AVG(f.fare_amount) AS avg_fare_amount,

    SUM(f.tip_amount) AS total_tips,

    AVG(f.tip_amount) AS avg_tip_amount,

    COUNT_IF(f.has_negative_fare) AS negative_fare_trips,

    COUNT_IF(f.has_negative_total) AS negative_total_trips,

    COUNT_IF(f.is_voided_trip) AS voided_trips

FROM {{ ref('fact_yellow_taxi_trips') }} f

LEFT JOIN {{ ref('dim_payment') }} p
    ON f.payment_key = p.payment_key

GROUP BY
    f.payment_key,
    p.payment_type