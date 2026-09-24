SELECT *
FROM {{ ref('stg_weather') }}
WHERE snowfall_mm < 0