{{ config(
    materialized='table',
    schema='MARTS'
) }}

SELECT
    f.pickup_location_key,

    pickup.zone AS pickup_zone,

    pickup.borough AS pickup_borough,

    f.dropoff_location_key,

    dropoff.zone AS dropoff_zone,

    dropoff.borough AS dropoff_borough,

    COUNT(*) AS total_trips,

    AVG(f.trip_distance) AS avg_trip_distance,

    AVG(f.trip_duration_minutes) AS avg_trip_duration_minutes,

    AVG(f.fare_amount) AS avg_fare_amount,

    SUM(f.total_amount) AS total_revenue,

    AVG(f.tip_amount) AS avg_tip_amount

FROM {{ ref('fact_yellow_taxi_trips') }} f

LEFT JOIN {{ ref('dim_location') }} pickup
    ON f.pickup_location_key = pickup.location_key

LEFT JOIN {{ ref('dim_location') }} dropoff
    ON f.dropoff_location_key = dropoff.location_key

WHERE f.has_invalid_datetime = FALSE

GROUP BY
    f.pickup_location_key,
    pickup.zone,
    pickup.borough,
    f.dropoff_location_key,
    dropoff.zone,
    dropoff.borough