{{ config(
    materialized='table',
    schema='MARTS'
) }}

WITH yellow_demand AS (

    SELECT
        date_key,
        pickup_location_key AS location_key,
        COUNT(*) AS yellow_trips

    FROM {{ ref('fact_yellow_taxi_trips') }}

    GROUP BY
        date_key,
        pickup_location_key
),

green_demand AS (

    SELECT
        date_key,
        pickup_location_key AS location_key,
        COUNT(*) AS green_trips

    FROM {{ ref('fact_green_taxi_trips') }}

    GROUP BY
        date_key,
        pickup_location_key
),

combined_demand AS (

    SELECT
        COALESCE(y.date_key, g.date_key) AS date_key,
        COALESCE(y.location_key, g.location_key) AS location_key,

        COALESCE(y.yellow_trips, 0) AS yellow_trips,
        COALESCE(g.green_trips, 0) AS green_trips,

        COALESCE(y.yellow_trips, 0)
            + COALESCE(g.green_trips, 0) AS total_trips

    FROM yellow_demand y

    FULL OUTER JOIN green_demand g
        ON y.date_key = g.date_key
        AND y.location_key = g.location_key
),

features AS (

    SELECT
        c.date_key,
        c.location_key,

        c.yellow_trips,
        c.green_trips,
        c.total_trips,

        d.full_date,

        DAYOFWEEK(d.full_date) AS day_of_week,
        DAYOFMONTH(d.full_date) AS day_of_month,
        MONTH(d.full_date) AS month,
        YEAR(d.full_date) AS year,

        CASE
            WHEN DAYOFWEEK(d.full_date) IN (1, 7)
            THEN 1
            ELSE 0
        END AS is_weekend,

        w.avg_temperature_c,
        w.precipitation_mm,
        w.snowfall_mm,

        LAG(c.total_trips, 1) OVER (
            PARTITION BY c.location_key
            ORDER BY c.date_key
        ) AS previous_day_trips,

        LAG(c.total_trips, 7) OVER (
            PARTITION BY c.location_key
            ORDER BY c.date_key
        ) AS previous_7_day_trips,

        AVG(c.total_trips) OVER (
            PARTITION BY c.location_key
            ORDER BY c.date_key
            ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
        ) AS rolling_7_day_avg_trips

    FROM combined_demand c

    INNER JOIN {{ ref('dim_date') }} d
        ON c.date_key = d.date_key

    LEFT JOIN {{ ref('mart_weather_daily') }} w
        ON c.date_key = w.date_key
)

SELECT *

FROM features

WHERE full_date >= '2024-01-01'
  AND full_date <= '2026-05-31'