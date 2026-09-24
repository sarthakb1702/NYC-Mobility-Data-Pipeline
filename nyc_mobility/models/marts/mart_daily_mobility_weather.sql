{{ config(
    materialized='table',
    schema='MARTS'
) }}

WITH yellow AS (

    SELECT
        date_key,

        total_trips AS yellow_trips,
        total_distance AS yellow_distance,
        avg_trip_distance AS yellow_avg_trip_distance,
        avg_trip_duration_minutes AS yellow_avg_trip_duration_minutes,
        total_fare_amount AS yellow_fare_amount,
        total_revenue AS yellow_revenue,
        avg_trip_amount AS yellow_avg_trip_amount

    FROM {{ ref('mart_yellow_daily_trips') }}

),

green AS (

    SELECT
        date_key,

        total_trips AS green_trips,
        total_distance AS green_distance,
        avg_trip_distance AS green_avg_trip_distance,
        avg_trip_duration_minutes AS green_avg_trip_duration_minutes,
        total_fare_amount AS green_fare_amount,
        total_revenue AS green_revenue,
        avg_trip_revenue AS green_avg_trip_revenue

    FROM {{ ref('mart_green_daily_trips') }}

),

weather AS (

    SELECT
        date_key,
        station_id,
        max_temperature_c,
        min_temperature_c,
        avg_temperature_c,
        precipitation_mm,
        snowfall_mm,
        has_precipitation,
        has_snowfall

    FROM {{ ref('mart_weather_daily') }}

)

SELECT

    d.date_key,
    d.full_date,

    -- =========================
    -- TRIP VOLUME
    -- =========================

    COALESCE(y.yellow_trips, 0) AS yellow_trips,

    COALESCE(g.green_trips, 0) AS green_trips,

    COALESCE(y.yellow_trips, 0)
        + COALESCE(g.green_trips, 0) AS total_trips,


    -- =========================
    -- DISTANCE
    -- =========================

    COALESCE(y.yellow_distance, 0) AS yellow_distance,

    COALESCE(g.green_distance, 0) AS green_distance,

    COALESCE(y.yellow_distance, 0)
        + COALESCE(g.green_distance, 0) AS total_distance,


    -- =========================
    -- AVERAGE TRIP METRICS
    -- =========================

    y.yellow_avg_trip_distance,

    g.green_avg_trip_distance,

    y.yellow_avg_trip_duration_minutes,

    g.green_avg_trip_duration_minutes,


    -- =========================
    -- FARE & REVENUE
    -- =========================

    COALESCE(y.yellow_fare_amount, 0) AS yellow_fare_amount,

    COALESCE(g.green_fare_amount, 0) AS green_fare_amount,

    COALESCE(y.yellow_fare_amount, 0)
        + COALESCE(g.green_fare_amount, 0) AS total_fare_amount,


    COALESCE(y.yellow_revenue, 0) AS yellow_revenue,

    COALESCE(g.green_revenue, 0) AS green_revenue,

    COALESCE(y.yellow_revenue, 0)
        + COALESCE(g.green_revenue, 0) AS total_revenue,


    y.yellow_avg_trip_amount,

    g.green_avg_trip_revenue,


    -- =========================
    -- WEATHER
    -- =========================

    w.station_id,

    w.max_temperature_c,

    w.min_temperature_c,

    w.avg_temperature_c,

    w.precipitation_mm,

    w.snowfall_mm,

    w.has_precipitation,

    w.has_snowfall


FROM {{ ref('dim_date') }} d

LEFT JOIN yellow y
    ON d.date_key = y.date_key

LEFT JOIN green g
    ON d.date_key = g.date_key

LEFT JOIN weather w
    ON d.date_key = w.date_key

WHERE d.full_date >= '2024-01-01'
  AND d.full_date <= '2026-05-31'