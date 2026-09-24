SELECT *
FROM {{ ref('stg_weather') }}
WHERE max_temperature_c < min_temperature_c