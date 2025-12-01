<div align="center">

# Modern Data Stack: Supply Chain Analytics (2025)

> A production-ready data pipeline showcasing AWS S3, Alteryx, Terraform, Snowflake, dbt, and Sigma Computing

<div align="center">
  <img src="https://github.com/user-attachments/assets/e5b423ed-e316-4928-b482-4445baebca43" alt="Supply Chain Analytics Dashboard" width="800"/>
</div>

</div>

[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![AWS](https://img.shields.io/badge/AWS-S3-orange)](https://aws.amazon.com/s3/)
[![Snowflake](https://img.shields.io/badge/Snowflake-Data%20Warehouse-blue)](https://www.snowflake.com/)
[![dbt](https://img.shields.io/badge/dbt-Transformations-ff6849)](https://www.getdbt.com/)
[![Terraform](https://img.shields.io/badge/Terraform-IaC-7B42BC)](https://www.terraform.io/)

---

## Project Overview

A complete end-to-end data pipeline demonstrating modern data engineering and business intelligence tools. We process **180K+ supply chain orders** and **470K+ clickstream events** through a multi-stage architecture that transforms raw data into actionable business insights.

This project showcases real-world data engineering practices: automated data ingestion, cloud storage, visual ETL, infrastructure as code, data warehousing, SQL transformations, and interactive BI dashboards.

---

## Architecture

<div align="center">

```mermaid
flowchart LR
    A[Kaggle] -->|dataFetcher.py| B[S3 Raw]
    B -->|Alteryx| C[S3 Processed]
    C -->|Terraform| D[AWS IAM]
    D -->|dataLoader.py| E[Snowflake]
    E -->|dbt| F[Analytics Marts]
    F -->|Sigma| G[BI Dashboard]
```

</div>

**Pipeline Flow:**
1. **Data Ingestion** - Automated download from Kaggle API to AWS S3
2. **Data Preparation** - Alteryx Designer Cloud workflows clean and enrich data
3. **Infrastructure** - Terraform provisions AWS IAM roles for secure Snowflake access
4. **Data Warehouse** - Snowflake stores and organizes data in structured schemas
5. **Transformations** - dbt models create analytics-ready datasets (staging → dimensions → facts → marts)
6. **Visualization** - Sigma Computing dashboard provides interactive business intelligence

---

## Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Data Source** | Kaggle API | Automated dataset downloads |
| **Storage** | AWS S3 | Data lake (raw & processed layers) |
| **ETL** | Alteryx Designer Cloud | Visual data preparation workflows |
| **Infrastructure** | Terraform | Infrastructure as Code (AWS IAM) |
| **Data Warehouse** | Snowflake | Centralized analytics database |
| **Transformations** | dbt (data build tool) | SQL-based data modeling |
| **BI & Analytics** | Sigma Computing | Interactive dashboards |

---

## Getting Started

**Prerequisites:** Python 3.8+, AWS account, Snowflake account, Alteryx access, Terraform, dbt-snowflake

```bash
# 1. Setup
./setup.sh
cp .env.example .env  # Add your credentials

# 2. Run the pipeline
python dataFetcher/dataFetcher.py              # Fetch data → S3
# Then follow instructions in each folder:
# - alteryxWorkflows/README.md (Alteryx ETL)
# - terraform/README.md (Infrastructure setup)
# - snowflakeIngestion/README.md (Snowflake loading)
# - dbtTransformations/README.md (dbt transformations)
```

Each component folder has detailed step-by-step guides.

---

## Project Structure

```
Project/
├── dataFetcher/              # Kaggle → S3 automated pipeline
├── alteryxWorkflows/         # Alteryx ETL workflows & formulas
├── terraform/                # Terraform IaC (AWS IAM)
├── snowflakeIngestion/       # S3 → Snowflake data loader
├── dbtTransformations/       # dbt SQL transformation models
├── rawData (reference only)/ # Sample raw data (15 rows)
└── processedData (reference only)/ # Sample processed data
```

---

## Pipeline Components

### 📥 Data Fetcher (Python + AWS S3)
Automated pipeline using Kaggle API and boto3. Downloads datasets and uploads to S3 data lake.

[<img width="486" height="53" alt="Data Fetcher" src="https://github.com/user-attachments/assets/962dff3d-9881-4733-898e-5f5740aed79a" />](./dataFetcher/README.md)

### 🔄 Alteryx Designer Cloud
Visual ETL workflows that clean, standardize, and enrich raw datasets. Adds calculated fields, temporal patterns, and session tracking.

[<img width="486" height="53" alt="Alteryx Workflows" src="https://github.com/user-attachments/assets/372b539d-8c4d-41ba-842a-9f8abf29b7d2" />](./alteryxWorkflows/README.md)

### ☁️ Terraform (Infrastructure as Code)
Provisions AWS IAM roles with S3 read permissions for Snowflake storage integration. Two-phase approach for secure credential management.

[<img width="486" height="53" alt="Terraform Infrastructure" src="https://github.com/user-attachments/assets/3857b7e3-c685-4da9-8c62-cfd4f4d64eba" />](./terraform/README.md)

### ❄️ Snowflake Data Warehouse
Loads processed data from S3 into Snowflake using `COPY INTO` commands. Creates structured schemas (RAWDATA, ANALYTICALDATA, MARTDATA).

[<img width="486" height="53" alt="Snowflake Ingestion" src="https://github.com/user-attachments/assets/074552a3-98ab-42a4-87b7-09ebbf876ae8" />](./snowflakeIngestion/README.md)

### 🔧 dbt Transformations
SQL-based data modeling following best practices: staging → dimensions → facts → analytics marts. Creates reusable, tested data models.

[<img width="486" height="53" alt="dbt Transformations" src="https://github.com/user-attachments/assets/8f20d3c1-4566-4ca7-a8d8-d0c0c1c4e0a5" />](./dbtTransformations/README.md)

---

## Business Intelligence Dashboard

The final layer uses **Sigma Computing** to create interactive business intelligence dashboards connected directly to Snowflake analytics marts.

**Connection:** Sigma → Snowflake → `MARTSALESPERFORMANCE` table

**Features:**
- Real-time data from Snowflake analytics marts
- Interactive KPI cards and charts
- Professional design with consistent color schemes
- Drill-down capabilities for deeper analysis

**To recreate:** Connect Sigma to Snowflake, select the analytics mart tables, and build visualizations. See dashboard screenshot above for reference.

---

## Dataset Information

- **Source:** [DataCo Supply Chain Dataset](https://data.mendeley.com/datasets/8gx2fvg2k6/5) (Mendeley Research)
- **Orders:** 180,519 rows, 53 columns → 58 columns (after Alteryx enrichment)
- **Clickstream:** 469,977 rows, 8 columns → 20 columns (after Alteryx enrichment)
- **Analytics Marts:** Pre-aggregated tables optimized for BI queries

---

## Environment Variables

See `.env.example` for required credentials:
- Kaggle API token
- AWS credentials (S3 access)
- Snowflake connection details

**Important:** Never commit `.env` to Git.

---

## License

MIT - See [LICENSE](./LICENSE)

---

**Built with:** Python, AWS S3, Alteryx, Terraform, Snowflake, dbt, Sigma Computing
