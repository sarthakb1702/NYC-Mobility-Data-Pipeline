from datetime import datetime

from airflow.sdk import DAG
from airflow.providers.standard.operators.bash import BashOperator
from airflow.providers.snowflake.operators.snowflake import SQLExecuteQueryOperator


with DAG(
    dag_id="nyc_mobility_pipeline",
    start_date=datetime(2026, 1, 1),
    schedule=None,
    catchup=False,
    tags=["nyc_mobility", "elt"],
) as dag:

    # =========================
    # RELOAD RAW DATA
    # =========================

    reload_raw = SQLExecuteQueryOperator(
        task_id="reload_raw",
        conn_id="nyc_mobility_snowflake",
        sql="""
            USE DATABASE NYC_MOBILITY;

            -- =========================
            -- YELLOW TAXI
            -- =========================

            TRUNCATE TABLE NYC_MOBILITY.RAW.YELLOW_TAXI_RAW;

            COPY INTO NYC_MOBILITY.RAW.YELLOW_TAXI_RAW
            FROM @NYC_MOBILITY.RAW.YELLOW_TAXI_STAGE
            FILE_FORMAT = NYC_MOBILITY.RAW.PARQUET_FORMAT
            MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
            ON_ERROR = 'CONTINUE';


            -- =========================
            -- GREEN TAXI
            -- =========================

            TRUNCATE TABLE NYC_MOBILITY.RAW.GREEN_TAXI_RAW;

            COPY INTO NYC_MOBILITY.RAW.GREEN_TAXI_RAW
            FROM @NYC_MOBILITY.RAW.GREEN_TAXI_STAGE
            FILE_FORMAT = NYC_MOBILITY.RAW.PARQUET_FORMAT
            MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
            ON_ERROR = 'CONTINUE';


            -- =========================
            -- WEATHER
            -- =========================

            TRUNCATE TABLE NYC_MOBILITY.RAW.WEATHER_RAW;

            COPY INTO NYC_MOBILITY.RAW.WEATHER_RAW
            FROM @NYC_MOBILITY.RAW.WEATHER_STAGE
            FILE_FORMAT = NYC_MOBILITY.RAW.PARQUET_FORMAT
            MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
            ON_ERROR = 'CONTINUE';
        """,
    )


    # =========================
    # DBT STAGING
    # =========================

    dbt_build_staging = BashOperator(
        task_id="dbt_build_staging",
        bash_command="""
            cd /opt/airflow/nyc_mobility

            export DBT_PROFILES_DIR=/opt/airflow/nyc_mobility

            dbt build --select staging
        """,
    )


    # =========================
    # DBT MARTS
    # =========================

    dbt_build_marts = BashOperator(
        task_id="dbt_build_marts",
        bash_command="""
            cd /opt/airflow/nyc_mobility

            export DBT_PROFILES_DIR=/opt/airflow/nyc_mobility

            dbt build --select marts
        """,
    )


    # =========================
    # DEPENDENCIES
    # =========================

    reload_raw >> dbt_build_staging >> dbt_build_marts