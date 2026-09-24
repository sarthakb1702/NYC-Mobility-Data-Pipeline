{{ config(
    materialized='table',
    schema='MARTS'
) }}

SELECT
    HASH(
        vendor_id,
        pickup_datetime,
        dropoff_datetime,
        pickup_location_id,
        dropoff_location_id,
        payment_type_id,
        rate_code_id,
        trip_distance,
        fare_amount,
        total_amount
    ) AS trip_key,

    COALESCE(
        TO_NUMBER(TO_CHAR(CAST(pickup_datetime AS DATE), 'YYYYMMDD')),
        0
    ) AS date_key,

    pickup_location_id AS pickup_location_key,

    dropoff_location_id AS dropoff_location_key,

    payment_type_id AS payment_key,

    COALESCE(rate_code_id, 0) AS rate_code_key,

    vendor_id,

    pickup_datetime,

    dropoff_datetime,

    passenger_count,

    trip_distance,

    trip_duration_minutes,

    fare_amount,

    extra,

    mta_tax,

    tip_amount,

    tolls_amount,

    improvement_surcharge,

    total_amount,

    congestion_surcharge,

    airport_fee,

    cbd_congestion_fee,

    store_and_forward,

    has_negative_fare,

    has_negative_total,

    has_negative_improvement_surcharge,

    has_negative_distance,

    has_invalid_datetime,

    is_voided_trip,

    is_zero_distance,

    has_invalid_passenger_count

FROM {{ ref('stg_yellow_taxi') }}
WHERE pickup_datetime >= '2024-01-01'
  AND pickup_datetime < '2027-01-01'