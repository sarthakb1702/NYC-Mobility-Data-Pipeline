import pandas as pd
import glob
import os

# Find the first Green Taxi Parquet file
files = glob.glob("data/green_trip/*.parquet")

if not files:
    print("No Green Taxi Parquet files found.")
    exit()

file = files[0]

# Read only the first file
df = pd.read_parquet(file)

print("File:", os.path.basename(file))
print("Rows:", len(df))
print("Columns:", len(df.columns))

print("\nColumns:")
for column in df.columns:
    print(column)

print("\nData Types:")
print(df.dtypes)