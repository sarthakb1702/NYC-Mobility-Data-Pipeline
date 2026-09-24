# 🚕 NYC Mobility Data Engineering & Analytics Platform

 An end-to-end **Data Engineering, Machine Learning, and Analytics project** built using NYC taxi trip and weather data.

 The project demonstrates a complete modern ELT pipeline:

 **S3 → Snowflake → dbt → Airflow → ML → Power BI**

---

 ## 🚀 Project Overview

 This platform processes **NYC Yellow Taxi, Green Taxi, and weather data** to build an analytics-ready data warehouse and machine learning pipeline.

 The project demonstrates the complete data lifecycle, from raw data ingestion and transformation to analytics, visualization, and machine learning predictions.

 ### 🔄 End-to-End Pipeline

```
NYC TLC + Weather Data
        ↓
    Amazon S3
        ↓
    Snowflake RAW
        ↓
    dbt STAGING
        ↓
    dbt MARTS
        ↓
   ┌────┴────┐
   ↓         ↓
Power BI    ML Models
             ↓
        Predictions
             ↓
         Snowflake
```

---

 ## 🛠️ Tech Stack

 - **Python** – Data processing, feature engineering, ML, and automation
- **SQL** – Data transformation and analytics
- **Amazon S3** – Cloud data storage and ingestion
- **Snowflake** – Cloud data warehouse
- **dbt** – Data transformation, modeling, and testing
- **Apache Airflow** – Workflow orchestration
- **Docker** – Containerization and development environment
- **XGBoost** – Machine learning models
- **Scikit-learn** – ML preprocessing and evaluation
- **Power BI** – Business intelligence and visualization
- **Git & GitHub** – Version control and collaboration

---

 # 📊 Data Engineering

 The Snowflake warehouse follows a layered architecture:

```
RAW → STAGING → MARTS
```

 ### RAW Layer

 The RAW layer stores source data loaded into Snowflake with minimal transformation.

 Data sources include:

 - NYC Yellow Taxi data
- NYC Green Taxi data
- NYC weather data

 ### STAGING Layer

 The STAGING layer performs initial transformations such as:

 - Data type standardization
- Column renaming
- Null handling
- Data cleaning
- Date and time transformations
- Basic data validation

 ### MARTS Layer

 The MARTS layer contains analytics-ready dimensional and fact models designed for reporting and machine learning.

 The project includes:

 - Dimensional models
- Analytical marts
- Taxi trip metrics
- Revenue metrics
- Pickup and drop-off analysis
- Route analysis
- Weather-related features
- Machine learning features

---

 ## 🧪 Data Quality

 The project uses **dbt tests** to validate the transformed data.

 Data quality checks cover:

 - Primary key uniqueness
- Not-null constraints
- Referential integrity
- Accepted values
- Data consistency
- Transformation correctness

 ### Test Results

```
75 dbt tests passed successfully
```

---

 # 🤖 Machine Learning

 The platform includes two machine learning pipelines built using **XGBoost**.

---

 ## 📍 1. Zone Demand Forecasting

 The demand forecasting model predicts **daily taxi demand by pickup zone**.

 The model uses historical taxi trip information and engineered features to estimate the number of trips for a given pickup zone and date.

 ### Model

```
XGBoost Regressor
```

 ### Evaluation Results

 | Metric | Result |
| --- | --- |
| MAE | 53.55 |
| RMSE | 157.10 |
| R² | 0.9798 |

The model is evaluated on **2026 test data**.

 ### Prediction Pipeline

```
Snowflake MARTS
      ↓
Feature Engineering
      ↓
XGBoost Model
      ↓
Demand Prediction
      ↓
Snowflake
      ↓
Power BI
```

---

 # ⏱️ 2. Trip Duration Prediction

 The second machine learning model predicts **taxi trip duration** using trip characteristics and weather information.

 ### Model

```
XGBoost Regressor
```

 ### Features Include

 - Pickup zone
- Drop-off zone
- Trip distance
- Passenger information
- Pickup time
- Day of week
- Weather conditions
- Other engineered trip characteristics

 ### Evaluation Results

 | Metric | Result |
| --- | --- |
| MAE | 3.75 minutes |
| RMSE | 6.52 minutes |
| R² | 0.7984 |

The model is evaluated on **2026 test data**.

 ### Prediction Pipeline

```
Snowflake MARTS
      ↓
Feature Engineering
      ↓
XGBoost Model
      ↓
Trip Duration Prediction
      ↓
Snowflake
      ↓
Power BI
```

---

 # 📈 Power BI

 The project includes interactive Power BI dashboards for both business analytics and machine learning performance.

---

 ## 🚕 NYC Mobility Overview

 The main mobility dashboard provides insights into NYC taxi operations.

 ### Dashboard Includes

 - Total trips
- Total revenue
- Daily trip trends
- Revenue trends
- Top pickup zones
- Popular routes
- Payment analysis
- Trip duration analysis

 ### Example Business Questions

```
How many taxi trips occurred over time?

Which pickup zones generate the most trips?

Which routes are most popular?

How does revenue change over time?

What payment methods are most commonly used?

How does trip duration vary across different areas and periods?
```

---

 # 🤖 ML & Prediction Dashboard

 The machine learning dashboard provides model performance and prediction analysis.

 ### Dashboard Includes

 - Demand model performance
- Actual vs predicted demand
- Trip duration model performance
- Actual vs predicted trip duration
- Model evaluation metrics
- Prediction analysis

 ### Example Visualizations

```
Actual Demand
      vs
Predicted Demand
```

```
Actual Trip Duration
      vs
Predicted Trip Duration
```

---

 # 🔄 Apache Airflow Orchestration

 Apache Airflow is used to orchestrate the end-to-end data pipeline.

 The workflow manages tasks such as:

```
Data Ingestion
      ↓
S3 Upload
      ↓
Snowflake Load
      ↓
dbt Staging
      ↓
dbt Marts
      ↓
Data Quality Tests
      ↓
ML Pipeline
      ↓
Predictions
      ↓
Snowflake
```

 Airflow provides:

 - Workflow scheduling
- Task dependencies
- Pipeline monitoring
- Retry handling
- Automated execution

---

 # ☁️ Cloud Architecture

 The project uses **Amazon S3** and **Snowflake** as the primary cloud data infrastructure.

```
             NYC TLC
                │
                ▼
          Weather Data
                │
                ▼
          ┌───────────┐
          │  Amazon   │
          │    S3     │
          └─────┬─────┘
                │
                ▼
       ┌─────────────────┐
       │    Snowflake    │
       │                 │
       │      RAW        │
       │       ↓         │
       │    STAGING      │
       │       ↓         │
       │     MARTS       │
       └───────┬─────────┘
               │
        ┌──────┴────────┐
        ▼               ▼
     Power BI       ML Models
                       │
                       ▼
                  Predictions
                       │
                       ▼
                   Snowflake
```

---

 # 📁 Project Structure

```
├── airflow/
│   └── dags/
│
├── config/
│
├── data/
│
├── nyc_mobility/
│   ├── models/
│   ├── macros/
│   ├── seeds/
│   └── tests/
│
├── notebooks/
│
├── scripts/
│
├── sql/
│
├── models/
│
├── tests/
│
├── requirements.txt
│
└── README.md
```

---

 # 🧱 Data Warehouse Architecture

 The warehouse follows a layered architecture to separate raw data, transformations, and analytics-ready datasets.

```
                    SOURCE DATA
                        │
             ┌──────────┴──────────┐
             │                     │
          NYC TLC               Weather
             │                     │
             └──────────┬──────────┘
                        ▼
                   Amazon S3
                        │
                        ▼
                ┌──────────────┐
                │  Snowflake   │
                │     RAW      │
                └──────┬───────┘
                       ▼
                ┌──────────────┐
                │     dbt      │
                │   STAGING    │
                └──────┬───────┘
                       ▼
                ┌──────────────┐
                │     dbt      │
                │    MARTS     │
                └──────┬───────┘
                       │
              ┌────────┴────────┐
              ▼                 ▼
          Power BI          ML Pipeline
                                │
                                ▼
                           Predictions
                                │
                                ▼
                            Snowflake
```

---

 # 🧪 Data Quality & Testing

 Data quality is integrated directly into the transformation pipeline using dbt.

 The project validates:

 - Uniqueness
- Null values
- Relationships
- Accepted values
- Data integrity
- Transformation correctness

 ### Validation Result

```
✔ 75 dbt tests passed successfully
```

---

 # 📊 Machine Learning Performance

 | Machine Learning Task | Model | MAE | RMSE | R² |
| --- | --- | --- | --- | --- |
| Zone Demand Forecasting | XGBoost | 53.55 | 157.10 | 0.9798 |
| Trip Duration Prediction | XGBoost | 3.75 min | 6.52 min | 0.7984 |

> The reported metrics are based on evaluation using 2026 test data.

---

 # 🎯 Key Skills Demonstrated

 ## Data Engineering

 - ELT architecture
- Data ingestion
- Data transformation
- Data modeling
- Data quality
- Cloud data warehousing
- Pipeline orchestration

 ## Cloud & Data Technologies

 - Amazon S3
- Snowflake
- dbt
- Apache Airflow
- Docker
- SQL
- Python

 ## Machine Learning

 - Feature engineering
- Regression modeling
- XGBoost
- Scikit-learn
- Model evaluation
- Prediction pipelines
- ML integration with data warehouses

 ## Analytics & BI

 - Power BI
- Business intelligence
- Data visualization
- KPI development
- Analytical dashboards
- Data-driven insights

 ## Development

 - Git
- GitHub
- Project organization
- Reproducible data pipelines

---

 # 💡 Project Highlights

```
✔ End-to-end ELT pipeline
✔ Amazon S3 data lake integration
✔ Snowflake cloud data warehouse
✔ RAW → STAGING → MARTS architecture
✔ dbt transformations
✔ 75 successful dbt tests
✔ Apache Airflow orchestration
✔ Docker-based environment
✔ XGBoost machine learning
✔ Taxi demand forecasting
✔ Trip duration prediction
✔ Power BI analytics dashboards
✔ ML prediction dashboards
✔ Predictions stored back in Snowflake
```

---

 # 🔄 End-to-End Workflow

 The complete platform can be summarized as:

```
1. Collect NYC taxi and weather data
                ↓
2. Store raw data in Amazon S3
                ↓
3. Load data into Snowflake RAW
                ↓
4. Transform data using dbt
                ↓
5. Build STAGING models
                ↓
6. Build analytical MARTS
                ↓
7. Run dbt data quality tests
                ↓
8. Orchestrate workflows with Airflow
                ↓
9. Generate ML features
                ↓
10. Train XGBoost models
                ↓
11. Evaluate models on 2026 test data
                ↓
12. Generate predictions
                ↓
13. Store predictions in Snowflake
                ↓
14. Build Power BI dashboards
```

---

 # 🏆 Project Outcome

 This project demonstrates how a modern data platform can combine **cloud data engineering, analytics, workflow orchestration, and machine learning** into a single end-to-end solution.

 The final platform enables:

 - Reliable ingestion of large-scale mobility data
- Structured analytical data modeling
- Automated data transformations
- Automated data quality validation
- Machine learning predictions
- Centralized prediction storage
- Interactive business intelligence dashboards
- Integration between data engineering, ML, and BI workflows

---

 # 🎯 Key Skills

 **Data Engineering • ELT • Snowflake • dbt • Apache Airflow • AWS S3 • SQL • Python • Machine Learning • XGBoost • Scikit-learn • Power BI • Docker • Git • GitHub • Data Analytics**
