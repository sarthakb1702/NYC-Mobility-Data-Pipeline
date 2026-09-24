import pandas as pd
import matplotlib

matplotlib.use("Agg")

import matplotlib.pyplot as plt


# ============================================================
# LOAD PREDICTIONS
# ============================================================

prediction_path = (
    "data/ml_predictions/"
    "trip_duration_predictions.csv"
)

df = pd.read_csv(
    prediction_path
)


# ============================================================
# CALCULATE METRICS
# ============================================================

actual = df[
    "TARGET_DURATION_MINUTES"
]

predicted = df[
    "PREDICTED_DURATION_MINUTES"
]


mae = (
    (actual - predicted)
    .abs()
    .mean()
)

rmse = (
    (
        (actual - predicted) ** 2
    ).mean()
    ** 0.5
)


print("\n==============================")
print("TRIP DURATION MODEL EVALUATION")
print("==============================")

print(
    f"MAE  : {mae:.2f} minutes"
)

print(
    f"RMSE : {rmse:.2f} minutes"
)


# ============================================================
# ACTUAL VS PREDICTED
# ============================================================

plt.figure(
    figsize=(10, 6)
)

plt.scatter(
    actual,
    predicted,
    alpha=0.15,
    s=5
)

plt.xlabel(
    "Actual Trip Duration (minutes)"
)

plt.ylabel(
    "Predicted Trip Duration (minutes)"
)

plt.title(
    "Actual vs Predicted Trip Duration"
)

max_value = max(
    actual.max(),
    predicted.max()
)

plt.plot(
    [0, max_value],
    [0, max_value],
    linestyle="--"
)

plt.tight_layout()

plt.savefig(
    "data/ml_predictions/"
    "trip_duration_actual_vs_predicted.png",
    dpi=150
)

plt.close()


# ============================================================
# ERROR DISTRIBUTION
# ============================================================

errors = (
    predicted - actual
)

plt.figure(
    figsize=(10, 6)
)

plt.hist(
    errors,
    bins=100
)

plt.xlabel(
    "Prediction Error (minutes)"
)

plt.ylabel(
    "Number of Trips"
)

plt.title(
    "Trip Duration Prediction Error Distribution"
)

plt.tight_layout()

plt.savefig(
    "data/ml_predictions/"
    "trip_duration_error_distribution.png",
    dpi=150
)

plt.close()


# ============================================================
# SUMMARY
# ============================================================

print("\nPlots saved to:")

print(
    "data/ml_predictions/"
    "trip_duration_actual_vs_predicted.png"
)

print(
    "data/ml_predictions/"
    "trip_duration_error_distribution.png"
)