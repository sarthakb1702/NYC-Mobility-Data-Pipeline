USE DATABASE NYC_MOBILITY;

-- =========================================================
-- ZONE DEMAND PREDICTIONS
-- =========================================================

TRUNCATE TABLE NYC_MOBILITY.MARTS.ML_ZONE_DEMAND_PREDICTIONS;

COPY INTO NYC_MOBILITY.MARTS.ML_ZONE_DEMAND_PREDICTIONS
FROM @NYC_MOBILITY.RAW.ML_ZONE_DEMAND_PREDICTIONS_STAGE
FILE_FORMAT = (
    TYPE = CSV
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
)
ON_ERROR = 'ABORT_STATEMENT';


-- =========================================================
-- TRIP DURATION PREDICTIONS
-- =========================================================

TRUNCATE TABLE NYC_MOBILITY.MARTS.ML_TRIP_DURATION_PREDICTIONS;

COPY INTO NYC_MOBILITY.MARTS.ML_TRIP_DURATION_PREDICTIONS
FROM @NYC_MOBILITY.RAW.ML_TRIP_DURATION_PREDICTIONS_STAGE
FILE_FORMAT = (
    TYPE = CSV
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
)
ON_ERROR = 'ABORT_STATEMENT';


-- =========================================================
-- VALIDATION
-- =========================================================

SELECT
    COUNT(*) AS zone_prediction_rows
FROM NYC_MOBILITY.MARTS.ML_ZONE_DEMAND_PREDICTIONS;


SELECT
    COUNT(*) AS trip_duration_prediction_rows
FROM NYC_MOBILITY.MARTS.ML_TRIP_DURATION_PREDICTIONS;