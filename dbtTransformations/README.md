# dbt Transformations

SQL-based data transformation pipeline for supply chain analytics. Transforms raw data from Snowflake into staging, dimensions, facts, and analytics marts using dbt.

## Prerequisites

- Python 3.8+
- dbt-snowflake installed: `pip install dbt-snowflake`
- Snowflake account with access to `SUPPLYCHAINDB` database
- Raw data loaded in `SUPPLYCHAINDB.RAWDATA` schema (via `snowflakeIngestion/dataLoader.py`)

## Setup

1. **Install dbt-snowflake:**
   ```bash
   pip install dbt-snowflake
   ```

2. **Configure Snowflake connection:**
   Copy `profiles.yml.example` to `~/.dbt/profiles.yml` and fill in your credentials:
   ```bash
   cp profiles.yml.example ~/.dbt/profiles.yml
   # Edit ~/.dbt/profiles.yml with your Snowflake credentials
   ```
   
   See `profiles.yml.example` for the full template.

3. **Verify connection:**
   ```bash
   cd dbtTransformations
   dbt debug
   ```

## Project Structure

```
models/
├── staging/              # Views (cleaned raw data)
│   ├── stgSupplyChainOrders.sql
│   └── stgClickstream.sql
├── marts/
│   ├── dimensions/      # Tables (customer, product, date)
│   │   ├── dimCustomers.sql
│   │   ├── dimProducts.sql
│   │   └── dimDates.sql
│   ├── facts/           # Tables (orders, clickstream)
│   │   ├── factOrders.sql
│   │   └── factClickstream.sql
│   └── analytics/       # Tables (pre-aggregated marts)
│       ├── martSalesPerformance.sql
│       ├── martCustomerAnalytics.sql
│       ├── martProductPerformance.sql
│       ├── martOperationalPerformance.sql
│       └── martClickstreamConversion.sql
└── sources.yml          # Raw data source definitions
```

## Usage

**Run all models:**
```bash
dbt run
```

**Run specific models:**
```bash
dbt run --select staging          # Only staging
dbt run --select dimensions       # Only dimensions
dbt run --select facts            # Only facts
dbt run --select analytics        # Only analytics marts
```

**Compile SQL (without running):**
```bash
dbt compile
```

**View compiled SQL:**
```bash
cat target/compiled/dbtTransformations/models/staging/stgSupplyChainOrders.sql
```

## Where Tables Are Saved

All tables/views are created in **Snowflake**, not locally:

- **Staging:** `SUPPLYCHAINDB.ANALYTICALDATA_ANALYTICALDATA.*` (views)
- **Dimensions/Facts:** `SUPPLYCHAINDB.ANALYTICALDATA_ANALYTICALDATA.*` (tables)
- **Analytics:** `SUPPLYCHAINDB.ANALYTICALDATA_MARTDATA.*` (tables)

Query from Snowflake UI or BI tools:
```sql
SELECT * FROM SUPPLYCHAINDB.ANALYTICALDATA_ANALYTICALDATA.DIMCUSTOMERS LIMIT 10;
```

## Common Hurdles

### 1. Schema Name Mismatch
**Issue:** Tables created in wrong schema (e.g., `ANALYTICALDATA_ANALYTICALDATA` instead of `ANALYTICALDATA`)

**Fix:** dbt appends schema name. Check `dbt_project.yml` for `+schema` settings. The double schema name is expected behavior when using custom schemas.

### 2. Source Tables Not Found
**Issue:** `Table 'SUPPLYCHAINDB.RAWDATA.DATACOSUPPLYCHAINORDERS' does not exist`

**Fix:** Run `snowflakeIngestion/dataLoader.py` first to load raw data into Snowflake.

### 3. Connection Errors
**Issue:** `Authentication failed` or `Database does not exist`

**Fix:** 
- Verify `profiles.yml` credentials
- Ensure Snowflake warehouse is running
- Check database name matches: `SUPPLYCHAINDB`

### 4. Column Name Case Issues
**Issue:** `invalid identifier 'PRODUCTID'` or similar

**Fix:** Raw tables use camelCase columns. Ensure `dataLoader.py` created tables with camelCase (not uppercase).

### 5. Materialization Errors
**Issue:** Views fail to create or tables are slow

**Fix:** 
- Staging models are views (fast creation, slower queries)
- Dimensions/facts/marts are tables (slower creation, faster queries)
- This is configured in `dbt_project.yml`

### 6. Foreign Key Mismatches
**Issue:** `dimProducts` join fails in `factClickstream`

**Fix:** Some clickstream products don't match orders. LEFT JOIN handles this (productId = NULL for unmatched).

## Model Dependencies

```
RAWDATA (Snowflake)
  ↓
staging (views)
  ↓
dimensions + facts (tables)
  ↓
analytics (tables)
```

Run in order: `staging` → `dimensions` → `facts` → `analytics` (or use `dbt run` which handles dependencies automatically).

## Verification

**Check row counts:**
```sql
SELECT COUNT(*) FROM SUPPLYCHAINDB.ANALYTICALDATA_ANALYTICALDATA.DIMCUSTOMERS;  -- 20,652
SELECT COUNT(*) FROM SUPPLYCHAINDB.ANALYTICALDATA_ANALYTICALDATA.FACTORDERS;     -- 180,519
SELECT COUNT(*) FROM SUPPLYCHAINDB.ANALYTICALDATA_MARTDATA.MARTSALESPERFORMANCE; -- 111,124
```

## Configuration Files

- `profiles.yml.example` - Template for Snowflake connection (copy to `~/.dbt/profiles.yml`)
- `.gitignore` - Excludes `target/`, `logs/`, `profiles.yml` from Git
- `.dbtignore` - Files to ignore during dbt parsing

**Important:** Never commit `profiles.yml` to Git (contains sensitive credentials). Use `profiles.yml.example` as a template.

## Next Steps

After running dbt models, connect BI tools (Sigma) to Snowflake and use the analytics marts for dashboards.
