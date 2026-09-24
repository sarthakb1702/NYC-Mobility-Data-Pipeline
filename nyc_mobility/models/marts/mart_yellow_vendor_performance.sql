{{ config(
    materialized='table',
    schema='MARTS'
) }}

SELECT
    vendor_id,

    COUNT(*) AS total_trips,

    SUM(trip_distance) AS total_distance,

    AVG(trip_distance) AS avg_trip_distance,

    AVG(
        CASE
            WHEN has_invalid_datetime = FALSE
            THEN trip_duration_minutes
        END
    ) AS avg_trip_duration_minutes,

    SUM(fare_amount) AS total_fare_amount,

    SUM(total_amount) AS total_revenue,

    AVG(total_amount) AS avg_trip_amount,

    SUM(tip_amount) AS total_tips,

    COUNT_IF(has_negative_fare) AS negative_fare_trips,

    COUNT_IF(has_invalid_datetime) AS invalid_datetime_trips,

    COUNT_IF(is_zero_distance) AS zero_distance_trips,

    COUNT_IF(has_invalid_passenger_count) AS invalid_passenger_trips

FROM {{ ref('fact_yellow_taxi_trips') }}

GROUP BY
    vendor_id