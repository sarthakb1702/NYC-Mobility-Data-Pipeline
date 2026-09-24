import os
import joblib
import pandas as pd
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import snowflake.connector

from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score


# ============================================================
# LOAD MODEL
# ============================================================

model_path = "models/zone_demand_xgboost.pkl"

model = joblib.load(model_path)


# ============================================================
# LOAD PREDICTIONS
# ============================================================

prediction_path = (
    "data/ml_predictions/"
    "zone_demand_predictions.csv"
)

df = pd.read_csv(prediction_path)

df["FULL_DATE"] = pd.to_datetime(df["FULL_DATE"])


# ============================================================
# METRICS
# ============================================================

mae = mean_absolute_error(
    df["TOTAL_TRIPS"],
    df["PREDICTED_TRIPS"]
)

rmse = mean_squared_error(
    df["TOTAL_TRIPS"],
    df["PREDICTED_TRIPS"]
) ** 0.5

r2 = r2_score(
    df["TOTAL_TRIPS"],
    df["PREDICTED_TRIPS"]
)

print("\n==============================")
print("ZONE DEMAND MODEL EVALUATION")
print("==============================")

print(f"MAE  : {mae:.2f}")
print(f"RMSE : {rmse:.2f}")
print(f"R²   : {r2:.4f}")


# ============================================================
# FEATURE IMPORTANCE
# ============================================================

feature_names = [
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

importance = pd.DataFrame({
    "feature": feature_names,
    "importance": model.feature_importances_
})

importance = importance.sort_values(
    "importance",
    ascending=False
)

print("\n==============================")
print("FEATURE IMPORTANCE")
print("==============================")

print(importance.to_string(index=False))


# ============================================================
# ACTUAL VS PREDICTED SAMPLE
# ============================================================

sample = df.sort_values(
    "FULL_DATE"
).head(20)

print("\n==============================")
print("SAMPLE PREDICTIONS")
print("==============================")

print(
    sample[
        [
            "FULL_DATE",
            "LOCATION_KEY",
            "TOTAL_TRIPS",
            "PREDICTED_TRIPS"
        ]
    ].to_string(index=False)
)


# ============================================================
# ACTUAL VS PREDICTED PLOT
# ============================================================

plt.figure(figsize=(10, 6))

plt.scatter(
    df["TOTAL_TRIPS"],
    df["PREDICTED_TRIPS"],
    alpha=0.3
)

min_value = min(
    df["TOTAL_TRIPS"].min(),
    df["PREDICTED_TRIPS"].min()
)

max_value = max(
    df["TOTAL_TRIPS"].max(),
    df["PREDICTED_TRIPS"].max()
)

plt.plot(
    [min_value, max_value],
    [min_value, max_value]
)

plt.xlabel("Actual Trips")
plt.ylabel("Predicted Trips")
plt.title("Zone Demand — Actual vs Predicted")

plt.tight_layout()

os.makedirs("data/ml_predictions", exist_ok=True)

plot_path = (
    "data/ml_predictions/"
    "zone_demand_actual_vs_predicted.png"
)

plt.savefig(plot_path)



print("\nPlot saved to:")
print(plot_path)


# ============================================================
# FEATURE IMPORTANCE PLOT
# ============================================================

plt.figure(figsize=(10, 6))

plot_data = importance.sort_values(
    "importance"
)

plt.barh(
    plot_data["feature"],
    plot_data["importance"]
)

plt.xlabel("Importance")
plt.ylabel("Feature")
plt.title("Zone Demand Model Feature Importance")

plt.tight_layout()

importance_path = (
    "data/ml_predictions/"
    "zone_demand_feature_importance.png"
)

plt.savefig(importance_path)



print("\nFeature importance plot saved to:")
print(importance_path)