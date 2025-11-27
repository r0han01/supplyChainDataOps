# Alteryx Transformation Workflows

This folder contains the transformation formulas and workflows used to clean and enrich the raw datasets from S3. Both workflows follow the same input pattern but produce different outputs.

**Important:** Alteryx Designer Cloud requires **"External Amazon S3"** connector (not standard "Amazon S3") to read/write files from S3 buckets.

---

## 🔄 Workflow 1: Supply Chain Orders

**Input:** `s3://dataco-supply-chain-analytics/raw/DataCoSupplyChainDataset.csv`  
**Output:** `s3://dataco-supply-chain-analytics/processed/DataCoSupplyChainDataset/DataCoSupplyChainDataset.csv`

### Process Flow

1. **External Amazon S3 Input** → Connect to S3 raw bucket, select `DataCoSupplyChainDataset.csv`
2. **Auto Column Tool** → Detect and convert data types (numeric fields, dates)
3. **Data Cleansing Tool** → Remove whitespace, standardize text casing, handle nulls
4. **Select Tool** → Drop 4 redundant columns (Customer Fname, Customer Lname, Product Image, Order Item Cardprod Id)
5. **Formula Tool (9 fields)** → Create calculated and temporal fields:
   - `profitMarginPct`: Calculate profit margin percentage
   - `profitCategory`: Categorize as High/Medium/Low/Loss based on margin
   - `deliveryDelay`: Calculate days between scheduled and actual delivery
   - `orderYear`, `orderMonth`, `orderQuarter`: Extract date components
   - `orderDayOfWeek`, `orderHour`: Extract temporal patterns
   - `isLate`: Binary flag for late deliveries
6. **External Amazon S3 Output** → Write to S3 processed bucket

**Result:** 53 columns → 58 columns (-4 dropped, +9 added)

### Workflow Diagram

<img width="886" height="328" alt="Alteryx workflow canvas showing tool connections" src="https://github.com/user-attachments/assets/655d5857-04fb-4d24-b6e3-51b4d1ca1db4" />


---

## 🔄 Workflow 2: Clickstream Events

**Input:** `s3://dataco-supply-chain-analytics/raw/tokenized_access_logs.csv`  
**Output:** `s3://dataco-supply-chain-analytics/processed/clickstreamDataPreparation/clickstreamDataPreparation.csv`

### Process Flow

1. **External Amazon S3 Input** → Connect to S3 raw bucket, select `tokenized_access_logs.csv`
2. **Auto Column Tool** → Detect and convert data types (Month, Hour, temporal fields)
3. **Data Cleansing Tool** → Remove whitespace, standardize Category/Department fields
4. **Formula Tool (12 fields)** → Create session tracking and behavioral fields:
   - `eventYear`, `eventMonth`, `eventQuarter`: Extract date components
   - `eventDayOfWeek`, `eventHourOfDay`: Extract temporal patterns
   - `isCartAdd`: Binary flag for cart additions (parsed from URL)
   - `eventType`: "Cart Add" or "Page View" label
   - `sessionDate`: Date without time for daily aggregations
   - `pageType`: Classify as Product/Category/Department page
   - `sessionID`: IP + date concatenation for session tracking
   - `isWeekend`: Binary flag for Saturday/Sunday
   - `timeOfDay`: Morning/Afternoon/Evening/Night categorization
5. **External Amazon S3 Output** → Write to S3 processed bucket

**Result:** 8 columns → 20 columns (+12 enrichment fields)

### Workflow Diagram

<img width="836" height="307" alt="Alteryx workflow canvas showing tool connections" src="https://github.com/user-attachments/assets/5044fb8f-93ab-4b70-9cf3-79f3bf5973ea" />

---

## 📋 Formula Reference

All formulas, field descriptions, and data types are documented in:
- `supplyChainTransformationFormulas.json` (9 added fields)
- `clickstreamTransformationFormulas.json` (12 added fields)

These JSON files contain the exact Alteryx formula syntax, tool configurations, and transformation logic used in the workflows.

---

## 🔧 S3 Configuration Notes

**Connection Details:**
- **Tool:** External Amazon S3 (not standard Amazon S3)
- **Authentication:** AWS Access Key + Secret Key (stored in Alteryx credentials manager)
- **Region:** Same as bucket region
- **Read Format:** CSV with header row
- **Write Format:** CSV with header row

Both workflows use the same S3 connection but different paths for input/output files.

---

**Next Step:** Processed files are automatically loaded into Snowflake for dbt transformations.

