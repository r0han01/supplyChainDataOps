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


## Overview

End-to-end data pipeline processing **180K+ orders** and **470K+ clickstream events** through a modern data stack: automated ingestion, cloud storage, visual ETL, infrastructure as code, data warehousing, SQL transformations, and interactive BI dashboards.

<div align="center">
  <img src="https://github.com/user-attachments/assets/e5b423ed-e316-4928-b482-4445baebca43" alt="Supply Chain Analytics Dashboard" width="800"/>
</div>

<br/>

## Architecture

**Workflow Explanation:**

The pipeline follows a modern data engineering pattern:

1. **Data Ingestion** (`dataFetcher.py`) - Python script downloads datasets from Kaggle API and uploads raw CSV files to AWS S3 raw bucket. Handles file format conversion and automated uploads.

2. **Data Preparation** (Alteryx Designer Cloud) - Visual ETL workflows read from S3 raw bucket, clean data (remove whitespace, standardize casing), and enrich with calculated fields (profit margins, temporal patterns, session tracking). Outputs processed CSV files back to S3 processed bucket.

3. **Infrastructure Setup** (Terraform) - Provisions AWS IAM role with S3 read permissions. Creates trust policy for Snowflake storage integration, enabling secure access to S3 buckets from Snowflake.

4. **Data Loading** (`dataLoader.py`) - Python script creates Snowflake database/schemas, defines file formats for CSV parsing, and loads processed data from S3 into Snowflake tables using `COPY INTO` commands. Handles ~180K orders and ~470K clickstream events.

5. **Data Transformation** (dbt) - SQL-based models transform raw data through layers: staging (views for cleaning), dimensions (customer, product, date tables), facts (orders, clickstream tables), and analytics marts (pre-aggregated business metrics). Creates reusable, tested data models.

6. **Business Intelligence** (Sigma Computing) - Interactive dashboard connects directly to Snowflake analytics marts. Builds KPI cards, charts, and visualizations for business insights. Real-time data access with drill-down capabilities.

<div align="center">
  <img width="700" alt="Architecture" src="https://github.com/user-attachments/assets/80ea219f-e6ad-43cb-8fa3-e08cc851d2ab" />
</div>

> **Is this workflow good?** Yes. It follows industry best practices: separation of concerns (ETL vs transformations), infrastructure as code, scalable cloud architecture, and modern data stack tools. Each component has a clear responsibility, making the pipeline maintainable and production-ready.

<br/>

<div align="center">

### Technologies & Tools

<a href="https://www.python.org/"><img src="https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white" alt="Python" style="margin: 0 10px;"/></a>
<a href="https://aws.amazon.com/s3/"><img src="https://img.shields.io/badge/AWS_S3-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white" alt="AWS S3" style="margin: 0 10px;"/></a>
<a href="https://www.snowflake.com/"><img src="https://img.shields.io/badge/Snowflake-29B5E8?style=for-the-badge&logo=snowflake&logoColor=white" alt="Snowflake" style="margin: 0 10px;"/></a>
<a href="https://www.getdbt.com/"><img src="https://img.shields.io/badge/dbt-FF694A?style=for-the-badge&logo=dbt&logoColor=white" alt="dbt" style="margin: 0 10px;"/></a>
<a href="https://www.terraform.io/"><img src="https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" alt="Terraform" style="margin: 0 10px;"/></a>
<a href="https://www.alteryx.com/"><img src="https://img.shields.io/badge/Alteryx-0078EF?style=for-the-badge&logo=alteryx&logoColor=white" alt="Alteryx" style="margin: 0 10px;"/></a>
<a href="https://www.sigmacomputing.com/"><img src="https://img.shields.io/badge/Sigma-FF6B35?style=for-the-badge&logo=sigmacomputing&logoColor=white" alt="Sigma Computing" style="margin: 0 10px;"/></a>

###
> 💡 **Prerequisites:** Make sure you have accounts ready for all services (they offer free trials). Store your credentials securely in `.env` file - see `.env.example` for required variables.

</div>

<br/>

## Installation & Configuration

### Project Approach

This project demonstrates both **UI-based** and **programmatic** workflows, providing flexibility for different skill levels and preferences:

- **Infrastructure (AWS S3)**: Create buckets manually via AWS Console or use Terraform (IaC)
- **Data Warehouse (Snowflake)**: Setup via Snowflake web UI or Python scripts (`dataLoader.py`)
- **Transformations (dbt)**: Use dbt Cloud (web UI) or dbt Core (command-line)
- **ETL (Alteryx)**: Visual Designer Cloud workflows with code-based formulas
- **BI (Sigma)**: Web-based dashboard builder connecting to Snowflake

All components include both UI and code options - choose what works best for you. Code is provided for automation and reproducibility.

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

### Troubleshooting

| Issue | Quick Fix |
|-------|-----------|
| **AWS IAM Role** - Cannot create with `:root` principal | Two-phase approach: Create role with AWS account ID first, then update trust policy with Snowflake IAM user ARN after storage integration |
| **Snowflake Account ID** - Documentation shows wrong account ID | Extract actual ID using `DESC STORAGE INTEGRATION` - different regions use different AWS account IDs |
| **Data Type Mismatches** - CSV columns don't match Snowflake schema | Define proper file formats with correct date/timestamp formats. Use `VARCHAR` initially, transform in dbt |
| **Schema Case Sensitivity** - Snowflake UPPERCASE vs dbt camelCase | Use uppercase schema names in `sources.yml` and `dbt_project.yml` to match Snowflake |
| **Alteryx Parquet** - Parquet not supported in Designer Cloud | Use CSV format for Alteryx compatibility |

> 💡 **Need more help?** Each component folder has detailed READMEs with step-by-step instructions.

<br/>

## Project Components

| Component | Purpose | Workflow | Documentation |
|-----------|---------|----------|---------------|
| **dataFetcher/** | Automated Kaggle dataset download and S3 upload | `Kaggle API → Local Cache → S3 Raw` | [📁 README](./dataFetcher/README.md) |
| **alteryxWorkflows/** | Visual ETL workflows for data cleaning and enrichment | `S3 Raw → Alteryx → Clean & Transform → S3 Processed` | [📁 README](./alteryxWorkflows/README.md) |
| **terraform/** | Infrastructure as Code for AWS IAM roles | `Terraform Config → AWS IAM Role → Snowflake Access` | [📁 README](./terraform/README.md) |
| **snowflakeIngestion/** | Python script to load processed data into Snowflake | `S3 Processed → COPY INTO → Snowflake Tables` | [📁 README](./snowflakeIngestion/README.md) |
| **dbtTransformations/** | SQL-based data modeling and transformations | `Raw Data → Staging → Dimensions/Facts → Analytics Marts` | [📁 README](./dbtTransformations/README.md) |


<br/>

## Business Intelligence Dashboard

**Sigma Computing** dashboard connected to Snowflake `MARTSALESPERFORMANCE` table. See dashboard screenshot above.

**To recreate:** Connect Sigma to Snowflake, select analytics mart tables, and build visualizations.

<br/>

## Dataset

- **Source:** [DataCo Supply Chain Dataset](https://data.mendeley.com/datasets/8gx2fvg2k6/5) (Mendeley)
- **Orders:** 180,519 rows (53 → 58 columns after enrichment)
- **Clickstream:** 469,977 rows (8 → 20 columns after enrichment)

---

## License

MIT - See [LICENSE](./LICENSE)
