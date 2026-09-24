from pathlib import Path
from datetime import date
import pandas as pd


# Project paths
PROJECT_ROOT = Path(__file__).resolve().parent.parent
INPUT_FILE = PROJECT_ROOT / "data" / "weather" / "USW00094728.dly"
OUTPUT_FILE = PROJECT_ROOT / "data" / "weather" / "nyc_daily_weather.parquet"


START_DATE = date(2024, 1, 1)
END_DATE = date(2026, 5, 31)


def parse_ghcn_dly(file_path):
    records = []

    with open(file_path, "r", encoding="utf-8") as file:
        for line in file:
            station_id = line[0:11]
            year = int(line[11:15])
            month = int(line[15:17])
            element = line[17:21]

            # Only keep the weather measurements we need
            if element not in {"TMAX", "TMIN", "PRCP", "SNOW"}:
                continue

            for day in range(1, 32):

                start = 21 + (day - 1) * 8

                value_text = line[start:start + 5]

                if not value_text.strip():
                    continue

                value = int(value_text)

                # -9999 means missing
                if value == -9999:
                    value = None

                try:
                    current_date = date(year, month, day)
                except ValueError:
                    continue

                if current_date < START_DATE or current_date > END_DATE:
                    continue

                # Convert GHCN units
                if value is not None:
                    if element in {"TMAX", "TMIN"}:
                        value = value / 10.0       # Celsius
                    elif element in {"PRCP", "SNOW"}:
                        value = value / 10.0       # mm

                records.append({
                    "station_id": station_id,
                    "date": current_date,
                    "element": element,
                    "value": value
                })

    return pd.DataFrame(records)


def main():
    print("Parsing NOAA GHCN weather data...")
    print(f"Input: {INPUT_FILE}")

    if not INPUT_FILE.exists():
        raise FileNotFoundError(
            f"Weather file not found: {INPUT_FILE}"
        )

    df = parse_ghcn_dly(INPUT_FILE)

    # Convert long format into daily columns
    df = df.pivot_table(
        index=["station_id", "date"],
        columns="element",
        values="value",
        aggfunc="first"
    ).reset_index()

    # Rename columns
    df = df.rename(columns={
        "TMAX": "max_temperature_c",
        "TMIN": "min_temperature_c",
        "PRCP": "precipitation_mm",
        "SNOW": "snowfall_mm"
    })

    # Make sure all expected columns exist
    expected_columns = [
        "station_id",
        "date",
        "max_temperature_c",
        "min_temperature_c",
        "precipitation_mm",
        "snowfall_mm"
    ]

    for column in expected_columns:
        if column not in df.columns:
            df[column] = None

    df = df[expected_columns]

    # Sort by date
    df = df.sort_values("date").reset_index(drop=True)

    # Save as Parquet
    df.to_parquet(
        OUTPUT_FILE,
        index=False
    )

    print("\nWeather parsing completed.")
    print(f"Output: {OUTPUT_FILE}")
    print(f"Rows: {len(df):,}")

    print("\nDate range:")
    print(f"Min date: {df['date'].min()}")
    print(f"Max date: {df['date'].max()}")

    print("\nSample:")
    print(df.head(10).to_string(index=False))

    print("\nMissing values:")
    print(df.isna().sum())


if __name__ == "__main__":
    main()