{{ config(
    materialized='table',
    schema='MARTS'
) }}

WITH trips AS (

    SELECT
        *,
        
        TO_NUMBER(
            TO_CHAR(pickup_datetime, 'YYYYMMDD')
        ) AS date_key

    FROM {{ ref('stg_green_taxi') }}

    WHERE pickup_datetime >= '2024-01-01'
      AND pickup_datetime < '2027-01-01'
)

SELECT
    MD5(
        CONCAT(
            COALESCE(t.vendor_id::VARCHAR, ''),
            '|',
            COALESCE(t.pickup_datetime::VARCHAR, ''),
            '|',
            COALESCE(t.dropoff_datetime::VARCHAR, ''),
            '|',
            COALESCE(t.pickup_location_id::VARCHAR, ''),
            '|',
            COALESCE(t.dropoff_location_id::VARCHAR, ''),
            '|',
            COALESCE(t.trip_distance::VARCHAR, ''),
            '|',
            COALESCE(t.fare_amount::VARCHAR, ''),
            '|',
            COALESCE(t.total_amount::VARCHAR, '')
        )
    ) AS trip_key,

    t.date_key,
    t.pickup_location_id AS pickup_location_key,
    t.dropoff_location_id AS dropoff_location_key,

    COALESCE(t.payment_type_id, 6) AS payment_key,
    COALESCE(t.rate_code_id, 0) AS rate_code_key,
    COALESCE(tt.trip_type_key, 0) AS trip_type_key,

    t.vendor_id,
    t.pickup_datetime,
    t.dropoff_datetime,
    t.passenger_count,
    t.trip_distance,
    t.trip_duration_minutes,
    t.fare_amount,
    t.extra,
    t.mta_tax,
    t.tip_amount,
    t.tolls_amount,
    t.ehail_fee,
    t.improvement_surcharge,
    t.congestion_surcharge,
    t.cbd_congestion_fee,
    t.total_amount,
    t.has_negative_distance,
    t.has_negative_fare,
    t.has_negative_improvement_surcharge,
    t.has_negative_total,
    t.has_invalid_datetime,
    t.is_voided_trip,
    t.is_zero_distance,
    t.has_invalid_passenger_count

FROM trips t

LEFT JOIN {{ ref('dim_trip_type') }} tt
    ON t.trip_type_id = tt.trip_type_key