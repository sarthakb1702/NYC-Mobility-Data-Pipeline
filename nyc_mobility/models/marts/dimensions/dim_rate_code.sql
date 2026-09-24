{{ config(
    materialized='table',
    schema='MARTS'
) }}

SELECT
    COALESCE(rate_code_id, 0) AS rate_code_key,

    rate_code_id,

    rate_code

FROM {{ ref('stg_yellow_taxi') }}

GROUP BY
    COALESCE(rate_code_id, 0),
    rate_code_id,
    rate_code