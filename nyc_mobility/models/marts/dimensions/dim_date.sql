{{ config(
    materialized='table',
    schema='MARTS'
) }}

WITH date_spine AS (

    SELECT
        DATEADD(
            'day',
            SEQ4(),
            DATE '2024-01-01'
        ) AS date_day

    FROM TABLE(
        GENERATOR(
            ROWCOUNT => 1096
        )
    )
),

dates AS (

    SELECT
        TO_NUMBER(TO_CHAR(date_day, 'YYYYMMDD')) AS date_key,

        date_day AS full_date,

        YEAR(date_day) AS year,

        QUARTER(date_day) AS quarter,

        MONTH(date_day) AS month,

        MONTHNAME(date_day) AS month_name,

        WEEKOFYEAR(date_day) AS week_of_year,

        DAY(date_day) AS day_of_month,

        DAYOFWEEK(date_day) AS day_of_week,

        DAYNAME(date_day) AS day_name,

        CASE
            WHEN DAYOFWEEK(date_day) IN (1, 7)
            THEN TRUE
            ELSE FALSE
        END AS is_weekend

    FROM date_spine
)

SELECT *
FROM dates