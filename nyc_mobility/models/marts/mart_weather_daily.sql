{{ config(
    materialized='table',
    schema='MARTS'
) }}

SELECT
    TO_NUMBER(
        TO_CHAR(weather_date, 'YYYYMMDD')
    ) AS date_key,

    station_id,

    max_temperature_c,
    min_temperature_c,
    avg_temperature_c,

    precipitation_mm,
    snowfall_mm,

    has_precipitation,
    has_snowfall

FROM {{ ref('stg_weather') }}