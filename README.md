# Supply Chain Analytics Pipeline

> From raw data to business insights in one pipeline. 180K orders, 470K clickstream events, and some pretty interesting findings.

<!-- Dashboard Image Placeholder -->
<!-- Add your Sigma dashboard screenshot here -->

---

## What This Is

A complete data pipeline that takes messy supply chain data and turns it into actionable insights. We found some wild stuff: **20% of orders are losing money** ($7.65M at risk), **revenue dropped 97% in 2018**, and the Consumer segment is carrying 52% of revenue.

Built with real tools you'd actually use in production: AWS S3, Snowflake, dbt, and Sigma. No toy examples here.

---

## The Pipeline

```
Kaggle → S3 → Alteryx → Snowflake → dbt → Sigma
```

**What happens:**
1. Download data from Kaggle, upload to S3
2. Clean and enrich with Alteryx (add profit margins, session tracking, etc.)
3. Load into Snowflake data warehouse
4. Transform with dbt (staging → dimensions → facts → analytics marts)
5. Visualize in Sigma dashboard

Each step has its own folder with detailed instructions. This README just gives you the big picture.

---

## Quick Start

**Prerequisites:** Python 3.8+, AWS account, Snowflake account, Alteryx access, Terraform, dbt

```bash
# 1. Setup
./setup.sh
cp .env.example .env  # Add your credentials

# 2. Run the pipeline
python dataFetcher/dataFetcher.py              # Fetch data
# Then follow instructions in each folder:
# - alteryxWorkflows/README.md
# - terraform/README.md  
# - snowflakeIngestion/README.md
# - dbtTransformations/README.md
```

That's it. Each component folder has step-by-step guides.

---

## What's Inside

| Folder | What It Does |
|--------|-------------|
| `dataFetcher/` | Downloads from Kaggle, uploads to S3 |
| `alteryxWorkflows/` | Cleans data, adds enrichment fields |
| `terraform/` | Sets up AWS IAM for Snowflake access |
| `snowflakeIngestion/` | Loads processed data into Snowflake |
| `dbtTransformations/` | SQL models: staging → dimensions → facts → marts |
| `rawData (reference only)/` | Sample files (15 rows each) for reference |

---

## The Dashboard

Built a Sigma dashboard that connects to the `MARTSALESPERFORMANCE` table in Snowflake. Shows revenue trends, profit margins, customer segments, and product performance.

**Key insights it reveals:**
- Revenue dropped 97% in 2018 (yikes)
- 20% of orders have negative margins ($7.65M at risk)
- Consumer segment = 52% of revenue
- Top 3 categories = 42% of revenue

**To recreate:** Connect Sigma to Snowflake, point it at `SUPPLYCHAINDB.ANALYTICALDATA_MARTDATA.MARTSALESPERFORMANCE`, and build away. The dashboard image above shows what it looks like.

---

## Tech Stack

- **Storage:** AWS S3 (data lake)
- **ETL:** Alteryx Designer Cloud
- **Infrastructure:** Terraform (AWS IAM)
- **Warehouse:** Snowflake
- **Transformations:** dbt
- **BI:** Sigma Computing

---

## Data

- **Source:** [DataCo Supply Chain Dataset](https://data.mendeley.com/datasets/8gx2fvg2k6/5) (Mendeley)
- **Orders:** 180,519 rows → 58 columns (after enrichment)
- **Clickstream:** 469,977 rows → 20 columns (after enrichment)
- **Analytics Marts:** Pre-aggregated tables for fast queries

---

## License

MIT - See [LICENSE](./LICENSE)

---

**Questions?** Check the README in each folder. They have all the details.
