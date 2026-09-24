{{ config(
    materialized='table',
    schema='MARTS'
) }}

WITH yellow AS (

    SELECT
        t.trip_key::VARCHAR AS trip_key,
        t.date_key,
        t.pickup_location_key,
        t.dropoff_location_key,
        t.pickup_datetime,
        t.passenger_count,
        t.trip_distance,
        t.rate_code_key,
        t.trip_duration_minutes,

        w.avg_temperature_c,
        w.precipitation_mm,
        w.snowfall_mm

    FROM {{ ref('fact_yellow_taxi_trips') }} t

    LEFT JOIN {{ ref('mart_weather_daily') }} w
        ON t.date_key = w.date_key

    WHERE t.trip_duration_minutes > 0
      AND t.trip_duration_minutes <= 180
      AND t.trip_distance > 0

),

green AS (

    SELECT
        t.trip_key::VARCHAR AS trip_key,
        t.date_key,
        t.pickup_location_key,
        t.dropoff_location_key,
        t.pickup_datetime,
        t.passenger_count,
        t.trip_distance,
        t.rate_code_key,
        t.trip_duration_minutes,

        w.avg_temperature_c,
        w.precipitation_mm,
        w.snowfall_mm

    FROM {{ ref('fact_green_taxi_trips') }} t

    LEFT JOIN {{ ref('mart_weather_daily') }} w
        ON t.date_key = w.date_key

    WHERE t.trip_duration_minutes > 0
      AND t.trip_duration_minutes <= 180
      AND t.trip_distance > 0

),

combined AS (

    SELECT
        'YELLOW' AS taxi_type,
        *
    FROM yellow

    UNION ALL

    SELECT
        'GREEN' AS taxi_type,
        *
    FROM green
)

SELECT

    trip_key,
    taxi_type,

    date_key,

    pickup_location_key,
    dropoff_location_key,

    pickup_datetime,

    passenger_count,
    trip_distance,
    rate_code_key,

    DAYOFWEEK(pickup_datetime) AS day_of_week,
    HOUR(pickup_datetime) AS pickup_hour,
    MONTH(pickup_datetime) AS month,

    CASE
        WHEN DAYOFWEEK(pickup_datetime) IN (1, 7)
        THEN 1
        ELSE 0
    END AS is_weekend,

    avg_temperature_c,
    precipitation_mm,
    snowfall_mm,

    trip_duration_minutes AS target_duration_minutes

FROM combined