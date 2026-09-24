import pandas as pd
import glob
import os

files = sorted(glob.glob("data/green_trip/*.parquet"))

if not files:
    print("No Green Taxi Parquet files found.")
    exit()

schemas = {}

for file in files:
    df = pd.read_parquet(file)

    columns = tuple(df.columns)

    schemas.setdefault(columns, []).append(os.path.basename(file))

print(f"Total files checked: {len(files)}")
print(f"Unique schemas found: {len(schemas)}")

for i, (columns, files_with_schema) in enumerate(schemas.items(), start=1):
    print(f"\n--- Schema {i} ---")
    print(f"Files: {len(files_with_schema)}")

    print("Example file:", files_with_schema[0])

    print("Columns:")
    for column in columns:
        print(column)

    if len(files_with_schema) <= 10:
        print("\nFiles:")
        for file in files_with_schema:
            print(file)
    else:
        print("\nFirst 5 files:")
        for file in files_with_schema[:5]:
            print(file)

print("\nSchema check completed.")