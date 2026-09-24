{{ config(
    materialized='table',
    schema='MARTS'
) }}

SELECT
    pickup_location_key AS location_key,

    COUNT(*) AS total_trips,

    SUM(passenger_count) AS total_passengers,

    SUM(trip_distance) AS total_distance,

    AVG(trip_distance) AS avg_trip_distance,

    AVG(trip_duration_minutes) AS avg_trip_duration_minutes,

    SUM(fare_amount) AS total_fare_amount,

    SUM(tip_amount) AS total_tip_amount,

    SUM(tolls_amount) AS total_tolls_amount,

    SUM(ehail_fee) AS total_ehail_fee,

    SUM(total_amount) AS total_revenue,

    AVG(total_amount) AS avg_trip_revenue

FROM {{ ref('fact_green_taxi_trips') }}

GROUP BY pickup_location_key