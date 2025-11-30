# Supply Chain Analytics Pipeline

> A production-ready data pipeline transforming raw supply chain data into actionable business intelligence dashboards.

<!-- Dashboard Image Placeholder -->
<!-- Add your Sigma dashboard screenshot here -->

---

## Overview

This project demonstrates a complete modern data stack, from raw data ingestion to interactive business intelligence. We process **180K+ supply chain orders** and **470K+ clickstream events** through a multi-stage pipeline that cleans, transforms, and visualizes data for strategic decision-making.

**What makes this special?** Every component is production-ready, using industry-standard tools (AWS S3, Snowflake, dbt, Sigma) with Infrastructure as Code (Terraform) and automated workflows. The pipeline reveals critical business insights: 20% of orders have negative margins ($7.65M at risk), revenue dropped 97% in 2018, and the Consumer segment drives 52% of revenue.

---

## Architecture

```
Kaggle Dataset
    ↓
[dataFetcher] → AWS S3 (Raw Data)
    ↓
[Alteryx] → AWS S3 (Processed Data)
    ↓
[Terraform] → AWS IAM + Snowflake Integration
    ↓
[Snowflake] → Data Warehouse (Raw → Analytics → Marts)
    ↓
[dbt] → SQL Transformations (Staging → Dimensions → Facts → Analytics)
    ↓
[Sigma] → Interactive BI Dashboard
```

### Pipeline Stages

1. **Data Ingestion** - Automated download from Kaggle to S3
2. **Data Preparation** - Alteryx workflows clean and enrich raw data
3. **Infrastructure** - Terraform provisions AWS IAM roles for Snowflake access
4. **Data Warehouse** - Snowflake stores and organizes data in schemas
5. **Transformations** - dbt models create analytics-ready datasets
6. **Visualization** - Sigma dashboard provides interactive insights

---

## Tech Stack

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **Data Source** | Kaggle API | Automated dataset downloads |
| **Storage** | AWS S3 | Data lake (raw & processed) |
| **Data Prep** | Alteryx Designer Cloud | Visual ETL workflows |
| **Infrastructure** | Terraform | AWS IAM role provisioning |
| **Data Warehouse** | Snowflake | Centralized analytics database |
| **Transformations** | dbt (data build tool) | SQL-based data modeling |
| **Visualization** | Sigma Computing | Interactive BI dashboards |

---

## Project Structure

```
Project/
├── dataFetcher/              # Automated Kaggle → S3 pipeline
├── alteryxWorkflows/         # Data preparation workflows & formulas
├── terraform/                # Infrastructure as Code (AWS IAM)
├── snowflakeIngestion/       # S3 → Snowflake data loader
├── dbtTransformations/       # SQL transformation models
├── rawData (reference only)/ # Sample raw data (15 rows)
├── processedData (reference only)/ # Sample processed data
├── localData/                # Full datasets (gitignored)
└── requirements.txt         # Python dependencies
```

---

## Getting Started

### Prerequisites

- Python 3.8+
- AWS account with S3 bucket
- Snowflake account
- Alteryx Designer Cloud (or access)
- Terraform (for infrastructure)
- dbt-snowflake (for transformations)

### Quick Setup

1. **Clone and setup:**
   ```bash
   git clone <repository-url>
   cd Project
   ./setup.sh
   ```

2. **Configure credentials:**
   ```bash
   cp .env.example .env
   # Edit .env with your Kaggle, AWS, and Snowflake credentials
   ```

3. **Run the pipeline:**
   ```bash
   # 1. Fetch data from Kaggle → S3
   python dataFetcher/dataFetcher.py
   
   # 2. Process data in Alteryx (manual: Designer Cloud UI)
   # 3. Setup infrastructure
   cd terraform/snowflakeS3Infra
   terraform init && terraform apply
   
   # 4. Load data into Snowflake
   cd ../../snowflakeIngestion
   python dataLoader.py
   
   # 5. Run dbt transformations
   cd ../dbtTransformations
   dbt run
   ```

See individual component READMEs for detailed instructions.

---

## Components

### 📥 Data Fetcher

Automated pipeline that downloads datasets from Kaggle and uploads to S3.

**Features:**
- Downloads 180K orders + 470K clickstream events
- Handles file format conversion (Parquet → CSV for Alteryx compatibility)
- Optional local storage with `--local-path` flag

**Usage:**
```bash
python dataFetcher/dataFetcher.py                    # Upload to S3
python dataFetcher/dataFetcher.py --local-path .      # Save locally
```

📖 [Read more →](./dataFetcher/README.md)

---

### 🔄 Alteryx Workflows

Visual data preparation workflows that clean and enrich raw datasets.

**What it does:**
- Removes whitespace, standardizes casing
- Calculates profit margins, delivery delays
- Extracts temporal patterns (year, quarter, day of week)
- Creates session tracking for clickstream data
- Adds 9 enrichment fields to orders, 12 to clickstream

**Output:** Processed CSV files in `s3://dataco-supply-chain-analytics/processed/`

📖 [Read more →](./alteryxWorkflows/README.md)

---

### ☁️ Infrastructure (Terraform)

Infrastructure as Code for AWS IAM roles enabling Snowflake S3 access.

**What it provisions:**
- AWS IAM role with S3 read permissions
- Trust policy for Snowflake storage integration
- Two-phase approach (initial role → update with Snowflake credentials)

**Usage:**
```bash
cd terraform/snowflakeS3Infra
terraform init
terraform plan
terraform apply
```

📖 [Read more →](./terraform/README.md)

---

### ❄️ Snowflake Ingestion

Loads processed data from S3 into Snowflake tables.

**What it does:**
- Creates database (`SUPPLYCHAINDB`) and schema (`RAWDATA`)
- Sets up file formats for CSV parsing
- Creates tables with camelCase column names
- Loads ~180K orders and ~470K clickstream events

**Usage:**
```bash
cd snowflakeIngestion
python dataLoader.py
```

📖 [Read more →](./snowflakeIngestion/README.md)

---

### 🔧 dbt Transformations

SQL-based data modeling that transforms raw data into analytics-ready datasets.

**Architecture:**
```
Raw Data (RAWDATA schema)
    ↓
Staging (Views) - Clean and standardize
    ↓
Dimensions (Tables) - Customers, Products, Dates
    ↓
Facts (Tables) - Orders, Clickstream Events
    ↓
Analytics Marts (Tables) - Pre-aggregated business metrics
```

**Key Models:**
- **Staging:** `stgSupplyChainOrders`, `stgClickstream`
- **Dimensions:** `dimCustomers`, `dimProducts`, `dimDates`
- **Facts:** `factOrders`, `factClickstream`
- **Analytics:** `martSalesPerformance`, `martCustomerAnalytics`, `martProductPerformance`, `martOperationalPerformance`, `martClickstreamConversion`

**Usage:**
```bash
cd dbtTransformations
dbt run                    # Run all models
dbt run --select staging   # Run specific layer
dbt docs generate          # Generate documentation
```

📖 [Read more →](./dbtTransformations/README.md)

---

## Visualization: Sigma Dashboard

The final layer of our pipeline uses **Sigma Computing** to create interactive business intelligence dashboards that bring our data to life.

### Dashboard Overview

**Supply Chain Sales Analytics Dashboard** provides comprehensive performance insights across revenue, profitability, customer segments, and product categories. The dashboard connects directly to our `MARTSALESPERFORMANCE` analytics mart in Snowflake, ensuring real-time access to transformed, business-ready data.

### Key Features

- **5 KPI Cards:** Total Revenue ($36.78M), Total Profit ($3.97M), Total Orders (159K), Profit Margin (10.78%), Unique Customers (159K)
- **6 Interactive Charts:**
  - Revenue Trend (2017-2018) - Highlights critical 97% revenue decline
  - Profit Margin Distribution - Shows 20% of orders with negative margins
  - Revenue by Customer Segment - Consumer segment drives 52% of revenue
  - Revenue by Geography - Geographic performance breakdown
  - Top Product Categories - Fishing leads with $6.9M revenue
  - Revenue by Department - Department-level performance
- **Key Insights Box:** Critical findings including revenue decline, margin risks, and segment performance

### Connection Setup

1. **Connect to Snowflake:**
   - In Sigma, create new data source
   - Select "Snowflake" connector
   - Enter connection details (account, warehouse, database: `SUPPLYCHAINDB`)
   - Authenticate with username/password

2. **Select Data Source:**
   - Database: `SUPPLYCHAINDB`
   - Schema: `ANALYTICALDATA_MARTDATA`
   - Table: `MARTSALESPERFORMANCE`

3. **Build Dashboard:**
   - Create KPI cards using aggregated metrics
   - Build charts using dimensions and measures
   - Apply professional color schemes and formatting
   - Add insights and annotations

### Dashboard Insights

The dashboard reveals critical business findings:

- **20% of orders have negative profit margins** ($7.65M revenue at risk)
- **Revenue dropped 97% in 2018** vs 2017 peak
- **Consumer segment drives 52% of revenue** (vs Corporate 30%, Home Office 18%)
- **Top 3 product categories account for 42% of revenue** (Fishing, Cleats, Camping & Hiking)

These insights highlight the need for immediate strategic intervention to address revenue decline, mitigate margin risks, and leverage the Consumer segment's dominant market position.

### Design Decisions

- **Color Scheme:** Professional gray gradients for bar charts, red for alerts/declines, multi-color for donut charts
- **Layout:** Clean 3-column grid with KPIs at top, charts organized by theme
- **Font Sizes:** 18px Bold for chart titles, consistent sizing throughout
- **Interactivity:** Filters and drill-downs enabled for deeper analysis

### Access

The dashboard is built in Sigma Computing and connects directly to Snowflake. To view or recreate:

1. Access your Sigma account
2. Connect to Snowflake using the connection details above
3. Select the `MARTSALESPERFORMANCE` table
4. Recreate the dashboard using the specifications above, or
5. Request access if the dashboard is shared

**Note:** Screenshots of the dashboard are available in the repository for reference.

---

## Data Flow

### Raw Data
- **Source:** [DataCo Supply Chain Dataset](https://data.mendeley.com/datasets/8gx2fvg2k6/5) (Mendeley Research)
- **Orders:** 180,519 rows, 53 columns
- **Clickstream:** 469,977 rows, 8 columns
- **Storage:** `s3://dataco-supply-chain-analytics/raw/`

### Processed Data
- **Orders:** 180,519 rows, 58 columns (+9 enrichment fields)
- **Clickstream:** 469,977 rows, 20 columns (+12 enrichment fields)
- **Storage:** `s3://dataco-supply-chain-analytics/processed/`

### Analytics Marts
- **Sales Performance:** 111,124 aggregated rows
- **Customer Analytics:** 20,652 customers
- **Product Performance:** Product-level metrics
- **Operational Performance:** Delivery and shipping metrics
- **Clickstream Conversion:** Funnel and conversion analysis

---

## Environment Variables

Required credentials (see `.env.example`):

```bash
# Kaggle
KAGGLE_API_TOKEN=your_token

# AWS
AWS_ACCESS_KEY_ID=your_key
AWS_SECRET_ACCESS_KEY=your_secret
AWS_DEFAULT_REGION=us-east-1

# Snowflake
SNOWFLAKE_ACCOUNT=your_account
SNOWFLAKE_USER=your_username
SNOWFLAKE_PASSWORD=your_password
SNOWFLAKE_WAREHOUSE=COMPUTE_WH
SNOWFLAKE_DATABASE=SUPPLYCHAINDB
```

**Important:** Never commit `.env` to Git. Use `.env.example` as a template.

---

## License

MIT License - See [LICENSE](./LICENSE) file for details.

---

## Contributing

This project demonstrates a complete modern data stack. Contributions, suggestions, and improvements are welcome!

For questions or issues, please open an issue in the repository.

---

**Built with:** Python, AWS S3, Alteryx, Terraform, Snowflake, dbt, Sigma Computing

