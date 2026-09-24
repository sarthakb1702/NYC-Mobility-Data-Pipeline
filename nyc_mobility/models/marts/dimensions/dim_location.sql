{{ config(
    materialized='table',
    schema='MARTS'
) }}

SELECT
    LOCATIONID AS location_key,

    LOCATIONID AS location_id,

    BOROUGH AS borough,

    ZONE AS zone,

    SERVICE_ZONE AS service_zone

FROM {{ ref('taxi_zone_lookup') }}