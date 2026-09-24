{{ config(
    materialized='table',
    schema='MARTS'
) }}

SELECT
    f.pickup_location_key AS location_key,

    l.borough,

    l.zone,

    l.service_zone,

    COUNT(*) AS total_trips,

    SUM(f.trip_distance) AS total_distance,

    AVG(f.trip_distance) AS avg_trip_distance,

    AVG(f.trip_duration_minutes) AS avg_trip_duration_minutes,

    SUM(f.fare_amount) AS total_fare_amount,

    SUM(f.total_amount) AS total_revenue,

    AVG(f.total_amount) AS avg_trip_amount,

    SUM(f.tip_amount) AS total_tips

FROM {{ ref('fact_yellow_taxi_trips') }} f

LEFT JOIN {{ ref('dim_location') }} l
    ON f.pickup_location_key = l.location_key

WHERE f.has_invalid_datetime = FALSE

GROUP BY
    f.pickup_location_key,
    l.borough,
    l.zone,
    l.service_zone