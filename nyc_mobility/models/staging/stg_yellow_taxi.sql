{{ config(materialized='view') }}

WITH cleaned AS (

    SELECT
        t.VENDORID AS vendor_id,

        t.TPEP_PICKUP_DATETIME AS pickup_datetime,

        t.TPEP_DROPOFF_DATETIME AS dropoff_datetime,

        NULLIF(t.PASSENGER_COUNT, 0) AS passenger_count,

        t.TRIP_DISTANCE AS trip_distance,

        CASE
            WHEN t.TRIP_DISTANCE < 0 THEN TRUE
            ELSE FALSE
        END AS has_negative_distance,

        t.RATECODEID AS rate_code_id,

        CASE
            WHEN t.RATECODEID = 1 THEN 'Standard Rate'
            WHEN t.RATECODEID = 2 THEN 'JFK'
            WHEN t.RATECODEID = 3 THEN 'Newark'
            WHEN t.RATECODEID = 4 THEN 'Nassau/Westchester'
            WHEN t.RATECODEID = 5 THEN 'Negotiated Fare'
            WHEN t.RATECODEID = 6 THEN 'Group Ride'
            WHEN t.RATECODEID = 99 THEN 'Unknown'
            ELSE 'Unknown'
        END AS rate_code,

        CASE
            WHEN t.STORE_AND_FWD_FLAG = 'Y' THEN 'Yes'
            WHEN t.STORE_AND_FWD_FLAG = 'N' THEN 'No'
            ELSE 'Unknown'
        END AS store_and_forward,

        t.PULOCATIONID AS pickup_location_id,

        pu.BOROUGH AS pickup_borough,

        pu.ZONE AS pickup_zone,

        pu.SERVICE_ZONE AS pickup_service_zone,

        t.DOLOCATIONID AS dropoff_location_id,

        do.BOROUGH AS dropoff_borough,

        do.ZONE AS dropoff_zone,

        do.SERVICE_ZONE AS dropoff_service_zone,

        t.PAYMENT_TYPE AS payment_type_id,

        CASE
            WHEN t.PAYMENT_TYPE = 0 THEN 'Flex Fare'
            WHEN t.PAYMENT_TYPE = 1 THEN 'Credit Card'
            WHEN t.PAYMENT_TYPE = 2 THEN 'Cash'
            WHEN t.PAYMENT_TYPE = 3 THEN 'No Charge'
            WHEN t.PAYMENT_TYPE = 4 THEN 'Dispute'
            WHEN t.PAYMENT_TYPE = 5 THEN 'Unknown'
            WHEN t.PAYMENT_TYPE = 6 THEN 'Voided'
            ELSE 'Unknown'
        END AS payment_type,

        t.FARE_AMOUNT AS fare_amount,

        CASE
            WHEN t.FARE_AMOUNT < 0 THEN TRUE
            ELSE FALSE
        END AS has_negative_fare,

        t.EXTRA AS extra,

        COALESCE(t.MTA_TAX, 0) AS mta_tax,

        COALESCE(t.TIP_AMOUNT, 0) AS tip_amount,

        COALESCE(t.TOLLS_AMOUNT, 0) AS tolls_amount,

        t.IMPROVEMENT_SURCHARGE AS improvement_surcharge,

        CASE
            WHEN t.IMPROVEMENT_SURCHARGE < 0 THEN TRUE
            ELSE FALSE
        END AS has_negative_improvement_surcharge,

        t.TOTAL_AMOUNT AS total_amount,

        CASE
            WHEN t.TOTAL_AMOUNT < 0 THEN TRUE
            ELSE FALSE
        END AS has_negative_total,

        COALESCE(t.CONGESTION_SURCHARGE, 0) AS congestion_surcharge,

        COALESCE(t.AIRPORT_FEE, 0) AS airport_fee,

        COALESCE(t.CBD_CONGESTION_FEE, 0) AS cbd_congestion_fee,

        DATEDIFF(
            'minute',
            t.TPEP_PICKUP_DATETIME,
            t.TPEP_DROPOFF_DATETIME
        ) AS trip_duration_minutes,

        CASE
            WHEN t.TPEP_DROPOFF_DATETIME <= t.TPEP_PICKUP_DATETIME
            THEN TRUE
            ELSE FALSE
        END AS has_invalid_datetime,

        CASE
            WHEN t.PAYMENT_TYPE = 6 THEN TRUE
            ELSE FALSE
        END AS is_voided_trip,

        CASE
            WHEN t.TRIP_DISTANCE = 0 THEN TRUE
            ELSE FALSE
        END AS is_zero_distance,

        CASE
            WHEN t.PASSENGER_COUNT IS NULL
              OR t.PASSENGER_COUNT = 0
            THEN TRUE
            ELSE FALSE
        END AS has_invalid_passenger_count

    FROM {{ source('raw', 'yellow_taxi_raw') }} t

    LEFT JOIN {{ ref('taxi_zone_lookup') }} pu
    ON t.PULOCATIONID = pu.LOCATIONID

    LEFT JOIN {{ ref('taxi_zone_lookup') }} do
    ON t.DOLOCATIONID = do.LOCATIONID

    WHERE
        t.TPEP_PICKUP_DATETIME IS NOT NULL
        AND t.TPEP_DROPOFF_DATETIME IS NOT NULL
)

SELECT *
FROM cleaned