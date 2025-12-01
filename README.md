<div align="center">

# Cloud-Native Supply Chain Analytics Platform

> A production-ready data pipeline showcasing AWS S3, Alteryx, Terraform, Snowflake, dbt, and Sigma Computing

<a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-green.svg" alt="MIT License" height="32"></a>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<a href="https://aws.amazon.com/s3/"><img src="https://img.shields.io/badge/AWS-S3-orange" alt="AWS S3" height="32"></a>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<a href="https://www.snowflake.com/"><img src="https://img.shields.io/badge/Snowflake-Data%20Warehouse-blue" alt="Snowflake" height="32"></a>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<a href="https://www.getdbt.com/"><img src="https://img.shields.io/badge/dbt-Transformations-ff6849" alt="dbt" height="32"></a>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<a href="https://www.terraform.io/"><img src="https://img.shields.io/badge/Terraform-IaC-7B42BC" alt="Terraform" height="32"></a>

</div>

---

## Overview

End-to-end data pipeline processing **180K+ orders** and **470K+ clickstream events** through a modern data stack: automated ingestion, cloud storage, visual ETL, infrastructure as code, data warehousing, SQL transformations, and interactive BI dashboards.

<div align="center">
  <img src="https://github.com/user-attachments/assets/e5b423ed-e316-4928-b482-4445baebca43" alt="Supply Chain Analytics Dashboard" width="800"/>
</div>

---

## Architecture

**Workflow Explanation:**

The pipeline follows a modern data engineering pattern:

1. **Data Ingestion** (`dataFetcher.py`) - Python script downloads datasets from Kaggle API and uploads raw CSV files to AWS S3 raw bucket. Handles file format conversion and automated uploads.

2. **Data Preparation** (Alteryx Designer Cloud) - Visual ETL workflows read from S3 raw bucket, clean data (remove whitespace, standardize casing), and enrich with calculated fields (profit margins, temporal patterns, session tracking). Outputs processed CSV files back to S3 processed bucket.

3. **Infrastructure Setup** (Terraform) - Provisions AWS IAM role with S3 read permissions. Creates trust policy for Snowflake storage integration, enabling secure access to S3 buckets from Snowflake.

4. **Data Loading** (`dataLoader.py`) - Python script creates Snowflake database/schemas, defines file formats for CSV parsing, and loads processed data from S3 into Snowflake tables using `COPY INTO` commands. Handles ~180K orders and ~470K clickstream events.

5. **Data Transformation** (dbt) - SQL-based models transform raw data through layers: staging (views for cleaning), dimensions (customer, product, date tables), facts (orders, clickstream tables), and analytics marts (pre-aggregated business metrics). Creates reusable, tested data models.

6. **Business Intelligence** (Sigma Computing) - Interactive dashboard connects directly to Snowflake analytics marts. Builds KPI cards, charts, and visualizations for business insights. Real-time data access with drill-down capabilities.

![Architecture](https://github.com/user-attachments/assets/2fc25bf5-7905-4797-947d-61a0b5b3691c)

**Is this workflow good?** Yes. It follows industry best practices: separation of concerns (ETL vs transformations), infrastructure as code, scalable cloud architecture, and modern data stack tools. Each component has a clear responsibility, making the pipeline maintainable and production-ready.

---

## Tech Stack

| Component | Technology |
|-----------|-----------|
| Data Source | Kaggle API |
| Storage | AWS S3 |
| ETL | Alteryx Designer Cloud |
| Infrastructure | Terraform |
| Data Warehouse | Snowflake |
| Transformations | dbt |
| BI & Analytics | Sigma Computing |

---

## How to Use This Project

### Prerequisites

- Python 3.8+
- AWS account with S3 bucket
- Snowflake account
- Alteryx Designer Cloud access
- Terraform installed
- dbt-snowflake installed

### Step-by-Step Setup

**1. Clone Repository**
```bash
git clone https://github.com/r0han01/supplyChainDataOps.git
cd supplyChainDataOps
```

**2. Environment Configuration**
```bash
# Setup Python virtual environment and install dependencies
./setup.sh

# Configure credentials
cp .env.example .env
# Edit .env with your credentials:
# - KAGGLE_API_TOKEN (from Kaggle account settings)
# - AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY (from AWS IAM)
# - S3_BUCKET_NAME (your S3 bucket name)
# - SNOWFLAKE_ACCOUNT, SNOWFLAKE_USER, SNOWFLAKE_PASSWORD
```

**3. Data Ingestion (Kaggle → S3)**
```bash
python dataFetcher/dataFetcher.py
# Downloads datasets from Kaggle and uploads to S3 raw bucket
```

**4. Data Preparation (Alteryx)**
- Open Alteryx Designer Cloud
- Import workflows from `alteryxWorkflows/`
- Connect to S3 raw bucket, run transformations
- Output processed files to S3 processed bucket
- See [`alteryxWorkflows/README.md`](./alteryxWorkflows/README.md) for detailed steps

**5. Infrastructure Setup (Terraform)**
```bash
cd terraform/snowflakeS3Infra
# Configure terraform.tfvars (see terraform.tfvars.example)
terraform init
terraform plan
terraform apply
# Creates AWS IAM role for Snowflake S3 access
# See [`terraform/README.md`](./terraform/README.md) for two-phase setup
```

**6. Data Loading (S3 → Snowflake)**
```bash
cd ../../snowflakeIngestion
# Ensure .env is configured with Snowflake credentials
python dataLoader.py
# Creates tables and loads processed data from S3
# See [`snowflakeIngestion/README.md`](./snowflakeIngestion/README.md) for verification queries
```

**7. Data Transformation (dbt)**
```bash
cd ../dbtTransformations
# Configure ~/.dbt/profiles.yml (see profiles.yml.example)
dbt debug
dbt run
# Transforms raw data into staging → dimensions → facts → analytics marts
# See [`dbtTransformations/README.md`](./dbtTransformations/README.md) for model details
```

**8. Business Intelligence (Sigma)**
- Connect Sigma to Snowflake
- Select analytics mart tables (e.g., `MARTSALESPERFORMANCE`)
- Build interactive dashboards with KPI cards and charts
- See dashboard screenshot above for reference

### Common Hurdles & Solutions

**1. AWS IAM Role Setup**
- **Issue:** Cannot create IAM role with `:root` principal via API/Terraform
- **Solution:** Two-phase approach: Create role with your AWS account ID first, then update trust policy with Snowflake IAM user ARN and External ID after creating storage integration

**2. Snowflake Account ID Confusion**
- **Issue:** Documentation shows generic account IDs that don't match your actual Snowflake account
- **Solution:** Extract actual AWS account ID from storage integration using `DESC STORAGE INTEGRATION` command. Different regions use different AWS account IDs.

**3. Data Type Mismatches**
- **Issue:** CSV columns don't match Snowflake table schema (e.g., strings in INT columns)
- **Solution:** Define proper file formats with correct date/timestamp formats. Use `VARCHAR` for mixed-type columns initially, then transform in dbt.

**4. Schema Name Case Sensitivity**
- **Issue:** Snowflake stores unquoted identifiers in UPPERCASE, but dbt expects camelCase
- **Solution:** Use uppercase schema names in `sources.yml` and `dbt_project.yml` to match Snowflake, or quote identifiers consistently.

**5. Alteryx Parquet Compatibility**
- **Issue:** Wanted to use Parquet for efficiency, but Alteryx Designer Cloud doesn't support Parquet preview
- **Solution:** Switched to CSV format for Alteryx compatibility while maintaining pipeline efficiency

Each component folder has detailed READMEs with step-by-step instructions and troubleshooting.

---

## Project Structure

```
Project/
├── dataFetcher/              # Kaggle → S3 pipeline
├── alteryxWorkflows/         # Alteryx ETL workflows
├── terraform/                # Terraform IaC
├── snowflakeIngestion/       # S3 → Snowflake loader
├── dbtTransformations/       # dbt SQL models
├── rawData (reference only)/ # Sample raw data
└── processedData (reference only)/ # Sample processed data
```

---

## Business Intelligence Dashboard

**Sigma Computing** dashboard connected to Snowflake `MARTSALESPERFORMANCE` table. See dashboard screenshot above.

**To recreate:** Connect Sigma to Snowflake, select analytics mart tables, and build visualizations.

---

## Dataset

- **Source:** [DataCo Supply Chain Dataset](https://data.mendeley.com/datasets/8gx2fvg2k6/5) (Mendeley)
- **Orders:** 180,519 rows (53 → 58 columns after enrichment)
- **Clickstream:** 469,977 rows (8 → 20 columns after enrichment)

---

## License

MIT - See [LICENSE](./LICENSE)
