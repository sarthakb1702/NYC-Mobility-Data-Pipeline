{{ config(
    materialized='table',
    schema='MARTS'
) }}

SELECT
    date_key,

    COUNT(*) AS total_trips,

    COUNT_IF(is_voided_trip = FALSE) AS completed_trips,

    COUNT_IF(is_zero_distance) AS zero_distance_trips,

    COUNT_IF(has_invalid_datetime) AS invalid_datetime_trips,

    COUNT_IF(has_negative_fare) AS negative_fare_trips,

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

    SUM(tolls_amount) AS total_tolls,

    SUM(congestion_surcharge) AS total_congestion_surcharge,

    SUM(airport_fee) AS total_airport_fees,

    SUM(cbd_congestion_fee) AS total_cbd_congestion_fee

FROM {{ ref('fact_yellow_taxi_trips') }}

GROUP BY
    date_key