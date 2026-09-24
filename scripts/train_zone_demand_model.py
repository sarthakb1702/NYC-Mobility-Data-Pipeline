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
# LOAD ML DATASET
# ============================================================

query = """
SELECT
    DATE_KEY,
    LOCATION_KEY,
    FULL_DATE,
    DAY_OF_WEEK,
    DAY_OF_MONTH,
    MONTH,
    YEAR,
    IS_WEEKEND,

    AVG_TEMPERATURE_C,
    PRECIPITATION_MM,
    SNOWFALL_MM,

    PREVIOUS_DAY_TRIPS,
    PREVIOUS_7_DAY_TRIPS,
    ROLLING_7_DAY_AVG_TRIPS,

    TOTAL_TRIPS

FROM NYC_MOBILITY.MARTS.ML_ZONE_DEMAND_FEATURES

WHERE PREVIOUS_DAY_TRIPS IS NOT NULL
  AND PREVIOUS_7_DAY_TRIPS IS NOT NULL
  AND ROLLING_7_DAY_AVG_TRIPS IS NOT NULL

ORDER BY FULL_DATE
"""

df = pd.read_sql(query, conn)

conn.close()

df["FULL_DATE"] = pd.to_datetime(df["FULL_DATE"])

# ============================================================
# PREPARE FEATURES
# ============================================================

features = [
    "LOCATION_KEY",
    "DAY_OF_WEEK",
    "DAY_OF_MONTH",
    "MONTH",
    "YEAR",
    "IS_WEEKEND",
    "AVG_TEMPERATURE_C",
    "PRECIPITATION_MM",
    "SNOWFALL_MM",
    "PREVIOUS_DAY_TRIPS",
    "PREVIOUS_7_DAY_TRIPS",
    "ROLLING_7_DAY_AVG_TRIPS"
]

target = "TOTAL_TRIPS"


X = df[features]
y = df[target]


# ============================================================
# TIME-BASED TRAIN / TEST SPLIT
# ============================================================

split_date = pd.Timestamp("2026-01-01")

train_mask = df["FULL_DATE"] < split_date
test_mask = df["FULL_DATE"] >= split_date

X_train = X.loc[train_mask]
X_test = X.loc[test_mask]

y_train = y.loc[train_mask]
y_test = y.loc[test_mask]


print("Training rows:", len(X_train))
print("Testing rows:", len(X_test))

print(
    "Training period:",
    df.loc[train_mask, "FULL_DATE"].min(),
    "to",
    df.loc[train_mask, "FULL_DATE"].max()
)

print(
    "Testing period:",
    df.loc[test_mask, "FULL_DATE"].min(),
    "to",
    df.loc[test_mask, "FULL_DATE"].max()
)


# ============================================================
# TRAIN XGBOOST MODEL
# ============================================================

model = XGBRegressor(
    n_estimators=500,
    max_depth=8,
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

predictions = model.predict(X_test)


# ============================================================
# MODEL EVALUATION
# ============================================================

mae = mean_absolute_error(y_test, predictions)

rmse = mean_squared_error(
    y_test,
    predictions
) ** 0.5

r2 = r2_score(
    y_test,
    predictions
)


print("\n==============================")
print("MODEL PERFORMANCE")
print("==============================")

print(f"MAE  : {mae:.2f}")
print(f"RMSE : {rmse:.2f}")
print(f"R²   : {r2:.4f}")


# ============================================================
# SAVE MODEL
# ============================================================

os.makedirs("models", exist_ok=True)

model_path = "models/zone_demand_xgboost.pkl"

joblib.dump(
    model,
    model_path
)

print("\nModel saved to:")
print(model_path)


# ============================================================
# SAVE TEST PREDICTIONS
# ============================================================

results = df.loc[test_mask, [
    "DATE_KEY",
    "LOCATION_KEY",
    "FULL_DATE",
    "TOTAL_TRIPS"
]].copy()

results["PREDICTED_TRIPS"] = predictions

os.makedirs("data/ml_predictions", exist_ok=True)

prediction_path = (
    "data/ml_predictions/"
    "zone_demand_predictions.csv"
)

results.to_csv(
    prediction_path,
    index=False
)

print("\nPredictions saved to:")
print(prediction_path)