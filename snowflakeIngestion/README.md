# Snowflake Data Ingestion

Loads processed data from S3 into Snowflake tables after Terraform infrastructure setup.

## Prerequisites

- Terraform setup completed (AWS IAM role and Snowflake storage integration configured)
- Processed data files available in S3: `processed/DataCoSupplyChainDataset/` and `processed/clickstreamDataPreparation/`
- Snowflake credentials configured

## Quick Start

### Option 1: Python Script (Automated)

```bash
# Set environment variables
export SNOWFLAKE_ACCOUNT="your_account"
export SNOWFLAKE_USER="your_username"
export SNOWFLAKE_PASSWORD="your_password"
# ... (see .env.example for all variables)

# Run loader
python3 dataLoader.py
```

### Option 2: Snowflake UI (Manual)

If you prefer using Snowflake's web interface, see [`manualIngestion.sql`](./manualIngestion.sql) for all SQL commands. Copy and paste into Snowflake Worksheets to execute.

## Environment Variables

Copy `.env.example` to `.env` and fill in your values:

```bash
cp .env.example .env
```

Required variables:
- `SNOWFLAKE_ACCOUNT` - Your Snowflake account identifier
- `SNOWFLAKE_USER` - Snowflake username
- `SNOWFLAKE_PASSWORD` - Snowflake password
- `SNOWFLAKE_STORAGE_INTEGRATION` - Storage integration name (default: `supplyChainS3Integration`)
- `S3_BUCKET_NAME` - S3 bucket name (default: `dataco-supply-chain-analytics`)

## What It Does

1. Creates database and schema if they don't exist
2. Creates file formats for CSV parsing (handles date formats)
3. Creates tables: `dataCoSupplyChainOrders` and `clickstreamEvents`
4. Loads data from S3 using `COPY INTO` commands
5. Returns row counts for verification

## Verification Queries (Snowflake UI)

After loading, run these in Snowflake Worksheets:

```sql
-- Check row counts
SELECT COUNT(*) FROM SUPPLYCHAINDB.RAWDATA.dataCoSupplyChainOrders;
SELECT COUNT(*) FROM SUPPLYCHAINDB.RAWDATA.clickstreamEvents;

-- Sample orders with Alteryx fields
SELECT "Order Id", "Product Name", profitMarginPct, profitCategory
FROM SUPPLYCHAINDB.RAWDATA.dataCoSupplyChainOrders
LIMIT 10;

-- Sample clickstream with enriched fields
SELECT "Product", eventType, sessionID, timeOfDay
FROM SUPPLYCHAINDB.RAWDATA.clickstreamEvents
LIMIT 10;
```

## Output

- **Orders**: ~180,519 rows
- **Clickstream**: ~469,977 rows

## Next Steps

After data is loaded into `RAWDATA` schema, proceed with dbt transformations in the `analyticalData` and `dataMarts` schemas.
