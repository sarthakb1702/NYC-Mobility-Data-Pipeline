{{ config(materialized='view') }}

SELECT
    STATION_ID AS station_id,
    DATE AS weather_date,

    MAX_TEMPERATURE_C AS max_temperature_c,
    MIN_TEMPERATURE_C AS min_temperature_c,
    PRECIPITATION_MM AS precipitation_mm,
    SNOWFALL_MM AS snowfall_mm,

    ROUND(
        (MAX_TEMPERATURE_C + MIN_TEMPERATURE_C) / 2,
        1
    ) AS avg_temperature_c,

    CASE
        WHEN PRECIPITATION_MM > 0 THEN TRUE
        ELSE FALSE
    END AS has_precipitation,

    CASE
        WHEN SNOWFALL_MM > 0 THEN TRUE
        ELSE FALSE
    END AS has_snowfall

FROM {{ source('raw', 'weather_raw') }}

WHERE DATE IS NOT NULL