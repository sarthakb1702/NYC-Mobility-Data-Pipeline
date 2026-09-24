import os
import joblib
import pandas as pd
import snowflake.connector

from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
from xgboost import XGBRegressor


# ============================================================
# SNOWFLAKE CONNECTION
# ============================================================

conn = snowflake.connector.connect(
    account="NEQBIAY-IF63337",
    user="sarthakb1702",
    password=os.environ["SNOWFLAKE_PASSWORD"],
    warehouse="NYC_MOBILITY_WH",
    database="NYC_MOBILITY",
    schema="MARTS",
    role="SYSADMIN"
)


# ============================================================
# QUERY
# ============================================================

query = """
SELECT
    TRIP_KEY,
    TAXI_TYPE,
    DATE_KEY,
    PICKUP_LOCATION_KEY,
    DROPOFF_LOCATION_KEY,
    PICKUP_DATETIME,
    PASSENGER_COUNT,
    TRIP_DISTANCE,
    RATE_CODE_KEY,
    DAY_OF_WEEK,
    PICKUP_HOUR,
    MONTH,
    IS_WEEKEND,
    AVG_TEMPERATURE_C,
    PRECIPITATION_MM,
    SNOWFALL_MM,
    TARGET_DURATION_MINUTES

FROM NYC_MOBILITY.MARTS.ML_TRIP_DURATION_FEATURES

WHERE TARGET_DURATION_MINUTES IS NOT NULL

  AND PICKUP_DATETIME >= '2024-01-01'

  AND PICKUP_DATETIME < '2026-06-01'

QUALIFY ROW_NUMBER() OVER (
    PARTITION BY TO_DATE(PICKUP_DATETIME)
    ORDER BY RANDOM()
)
<=
CASE
    WHEN PICKUP_DATETIME < '2026-01-01'
    THEN 1000
    ELSE 2000
END
"""


# ============================================================
# LOAD DATA IN BATCHES
# ============================================================

print("Loading training data from Snowflake...")

cursor = conn.cursor()
cursor.execute(query)

columns = [column[0] for column in cursor.description]

chunks = []

batch_size = 50000

while True:

    rows = cursor.fetchmany(batch_size)

    if not rows:
        break

    chunk = pd.DataFrame(
        rows,
        columns=columns
    )

    chunks.append(chunk)

    print(
        f"Loaded {sum(len(c) for c in chunks):,} rows..."
    )


cursor.close()
conn.close()


if not chunks:
    raise RuntimeError("No training data was returned from Snowflake.")


df = pd.concat(
    chunks,
    ignore_index=True
)

del chunks


print(
    "\nTotal rows loaded:",
    f"{len(df):,}"
)


# ============================================================
# DATA PREPARATION
# ============================================================

df["PICKUP_DATETIME"] = pd.to_datetime(
    df["PICKUP_DATETIME"]
)

df["PASSENGER_COUNT"] = (
    df["PASSENGER_COUNT"]
    .fillna(1)
)

df["AVG_TEMPERATURE_C"] = (
    df["AVG_TEMPERATURE_C"]
    .fillna(0)
)

df["PRECIPITATION_MM"] = (
    df["PRECIPITATION_MM"]
    .fillna(0)
)

df["SNOWFALL_MM"] = (
    df["SNOWFALL_MM"]
    .fillna(0)
)


# ============================================================
# TIME-BASED TRAIN / TEST SPLIT
# ============================================================

split_date = pd.Timestamp(
    "2026-01-01"
)

train_mask = (
    df["PICKUP_DATETIME"] < split_date
)

test_mask = (
    df["PICKUP_DATETIME"] >= split_date
)

train_df = df.loc[
    train_mask
].copy()

test_df = df.loc[
    test_mask
].copy()


print(
    "\nTraining rows:",
    f"{len(train_df):,}"
)

print(
    "Testing rows:",
    f"{len(test_df):,}"
)

print(
    "Training period:",
    train_df["PICKUP_DATETIME"].min(),
    "to",
    train_df["PICKUP_DATETIME"].max()
)

print(
    "Testing period:",
    test_df["PICKUP_DATETIME"].min(),
    "to",
    test_df["PICKUP_DATETIME"].max()
)


# ============================================================
# FEATURES
# ============================================================

features = [

    "PICKUP_LOCATION_KEY",

    "DROPOFF_LOCATION_KEY",

    "PASSENGER_COUNT",

    "TRIP_DISTANCE",

    "RATE_CODE_KEY",

    "DAY_OF_WEEK",

    "PICKUP_HOUR",

    "MONTH",

    "IS_WEEKEND",

    "AVG_TEMPERATURE_C",

    "PRECIPITATION_MM",

    "SNOWFALL_MM"
]

target = (
    "TARGET_DURATION_MINUTES"
)


X_train = train_df[
    features
]

y_train = train_df[
    target
]

X_test = test_df[
    features
]

y_test = test_df[
    target
]


# ============================================================
# TRAIN MODEL
# ============================================================

print(
    "\nTraining XGBoost model..."
)

model = XGBRegressor(

    n_estimators=500,

    max_depth=10,

    learning_rate=0.05,

    subsample=0.8,

    colsample_bytree=0.8,

    objective="reg:squarederror",

    random_state=42,

    n_jobs=-1
)


model.fit(
    X_train,
    y_train
)


# ============================================================
# PREDICTIONS
# ============================================================

predictions = model.predict(
    X_test
)


# ============================================================
# MODEL EVALUATION
# ============================================================

mae = mean_absolute_error(
    y_test,
    predictions
)

rmse = (
    mean_squared_error(
        y_test,
        predictions
    )
    ** 0.5
)

r2 = r2_score(
    y_test,
    predictions
)


print(
    "\n=============================="
)

print(
    "TRIP DURATION MODEL PERFORMANCE"
)

print(
    "=============================="
)

print(
    f"MAE  : {mae:.2f} minutes"
)

print(
    f"RMSE : {rmse:.2f} minutes"
)

print(
    f"R²   : {r2:.4f}"
)


# ============================================================
# FEATURE IMPORTANCE
# ============================================================

importance = pd.DataFrame({

    "feature": features,

    "importance":
        model.feature_importances_

})

importance = importance.sort_values(

    "importance",

    ascending=False

)


print(
    "\n=============================="
)

print(
    "FEATURE IMPORTANCE"
)

print(
    "=============================="
)

print(
    importance.to_string(
        index=False
    )
)


# ============================================================
# SAVE MODEL
# ============================================================

os.makedirs(
    "models",
    exist_ok=True
)

model_path = (
    "models/"
    "trip_duration_xgboost.pkl"
)

joblib.dump(
    model,
    model_path
)

print(
    "\nModel saved to:"
)

print(
    model_path
)


# ============================================================
# SAVE PREDICTIONS
# ============================================================

results = test_df[

    [
        "TRIP_KEY",

        "TAXI_TYPE",

        "DATE_KEY",

        "PICKUP_LOCATION_KEY",

        "DROPOFF_LOCATION_KEY",

        "PICKUP_DATETIME",

        "TRIP_DISTANCE",

        "TARGET_DURATION_MINUTES"
    ]

].copy()


results[
    "PREDICTED_DURATION_MINUTES"
] = predictions


os.makedirs(
    "data/ml_predictions",
    exist_ok=True
)


prediction_path = (

    "data/ml_predictions/"

    "trip_duration_predictions.csv"

)


results.to_csv(

    prediction_path,

    index=False

)


print(
    "\nPredictions saved to:"
)

print(
    prediction_path
)