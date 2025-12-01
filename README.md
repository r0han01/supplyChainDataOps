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

## Dataset

<div align="center">

### DataCo SMART Supply Chain for Big Data Analysis

</div>

**Why This Dataset?**

Supply chain analytics is critical for modern businesses, especially in the USA where logistics and distribution networks drive economic efficiency. This dataset provides real-world insights into order fulfillment, customer behavior, product performance, and operational metrics - making it ideal for demonstrating end-to-end data engineering and business intelligence capabilities.

**Industry Relevance:**

- **Supply Chain Market:** The US supply chain market is valued at $37+ billion and growing, with companies investing heavily in data-driven optimization
- **E-commerce Growth:** Online retail continues to expand, requiring sophisticated analytics for inventory, shipping, and customer satisfaction
- **Operational Excellence:** Companies use supply chain data to reduce costs, improve delivery times, and enhance customer experience
- **Business Intelligence:** Supply chain metrics directly impact revenue, profit margins, and competitive advantage

**Dataset Details:**

<table align="center">
  <tr>
    <th align="left">Metric</th>
    <th align="left">Value</th>
  </tr>
  <tr>
    <td><strong>Orders Dataset</strong></td>
    <td>180,519 rows • 53 → 58 columns (after enrichment)</td>
  </tr>
  <tr>
    <td><strong>Clickstream Dataset</strong></td>
    <td>469,977 rows • 8 → 20 columns (after enrichment)</td>
  </tr>
  <tr>
    <td><strong>Data Sources</strong></td>
    <td>
      <a href="https://www.kaggle.com/datasets/shashwatwork/dataco-smart-supply-chain-for-big-data-analysis">📊 Kaggle</a> • 
      <a href="https://data.mendeley.com/datasets/8gx2fvg2k6/5">📚 Mendeley</a>
    </td>
  </tr>
</table>

**Key Features:**
- Order fulfillment metrics (delivery status, shipping times, profit margins)
- Customer segmentation and behavior analysis
- Product performance and category insights
- Clickstream data for conversion funnel analysis
- Geographic and temporal patterns

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

##

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

<div align="center">

### BI Tool Selection

<div align="center">
  <!-- Sigma Logo - Add image URL here -->
  <img src="https://github.com/user-attachments/assets/8f2a399a-e9f7-48b5-8883-e9a73fa9ca23" alt="Sigma Computing" width="150" style="margin: 20px;"/>
</div>

</div>

**Why Sigma Computing?**

Sigma was chosen for this project as it's one of the best cloud-based BI tools for learning and rapid dashboard development. It requires minimal training and offers a user-friendly interface that makes it accessible for data professionals transitioning into BI roles.

**Tool Comparison:**

<div align="center">
  <!-- Power BI Logo - Add image URL here -->
  <img src="https://github.com/user-attachments/assets/755521e6-e70b-4630-938d-cae587614dad" alt="Microsoft Power BI" width="150" style="margin: 20px;"/>
</div>

##

While **Power BI** offers more advanced features, integrated tools, and extensive formatting capabilities, **Sigma** excels in simplicity and quick deployment. However, Sigma has limitations in formatting options and advanced analytics features compared to Power BI's comprehensive toolkit.

**For This Project:**

- **Connection:** Sigma → Snowflake `MARTSALESPERFORMANCE` table
- **Dashboard:** Interactive KPI cards, charts, and visualizations (see screenshot above)
- **To Recreate:** Connect Sigma to Snowflake, select analytics mart tables, and build visualizations

> 💡 **Note:** For production environments requiring advanced analytics, Power BI may be a better choice. Sigma is ideal for quick prototyping and cloud-native BI workflows.

---

## How to Contribute

This project currently showcases one dashboard, but we have **4 additional analytics marts** ready for exploration:

- `martSalesPerformance` - Sales metrics by time, segment, and category
- `martOperationalPerformance` - Delivery and shipping metrics
- `martClickstreamConversion` - Conversion funnel analysis
- `martCustomerAnalytics` - Customer behavior and value segmentation
- `martProductPerformance` - Product sales and profitability rankings

**Create Your Own Dashboard:**

You can use any BI tool to build dashboards from these marts. Popular options include:

- **Sigma Computing** (cloud-native, easy setup)
- **Microsoft Power BI** (advanced features, comprehensive toolkit)
- **Tableau** (powerful visualizations, enterprise-grade)
- **Looker** (data modeling focus, embedded analytics)
- **Metabase** (open-source, self-hosted option)
- **Apache Superset** (open-source, Python-based)

**Step-by-Step Process:**

1. **Complete the Pipeline Setup** (follow steps 1-7 in Installation & Configuration)
2. **Run dbt Models** - Ensure all analytics marts are created in Snowflake:
   ```bash
   cd dbtTransformations
   dbt run --select marts.analytics.*
   ```
3. **Connect Your BI Tool to Snowflake:**
   - Get Snowflake connection details (account, user, password, warehouse, database)
   - In your BI tool, create a new data source connection
   - Select `SUPPLYCHAINDB` database → `MARTDATA` schema
   - Choose any analytics mart table (e.g., `MARTSALESPERFORMANCE`)
4. **Build Your Dashboard:**
   - Create visualizations using the mart tables
   - Experiment with different metrics and dimensions
   - Design a professional, production-ready dashboard
5. **Submit Your Work:**
   - Open a Pull Request with screenshots of your dashboard
   - Include a brief description of your analysis and insights
   - We'll review and accept high-quality contributions!

**Need Help?**

If you encounter any issues or have questions:
- **Email:** hello@rkatkam.com
- **Subject:** `[supplyChainDataOps] <Your Issue/Question>`
- We'll respond promptly to help you succeed!

> 💡 **Pro Tip:** Start with `martSalesPerformance` - it has the most comprehensive metrics and is perfect for building your first dashboard. Once comfortable, explore the other marts for deeper insights!

---

## License

MIT - See [LICENSE](./LICENSE)
