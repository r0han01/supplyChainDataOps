# Processed Data (Reference Only)

This folder contains **sample outputs** (15 rows each) from Alteryx transformations. These are cleaned, enriched versions of the raw datasets with additional analytical fields to support business intelligence work.

---

## 📦 Datasets

### 1. DataCoSupplyChainDataset.csv
**Original:** 53 columns → **Processed:** 58 columns (+9 enrichment fields)

### 2. clickstreamDataPreparation.csv  
**Original:** 8 columns → **Processed:** 20 columns (+12 enrichment fields)

---

## ➕ Added Fields: Supply Chain Orders

These fields were added to enable profitability analysis, temporal patterns, and delivery performance tracking without requiring complex calculations in downstream tools.

| Field Name | Type | Description |
|------------|------|-------------|
| profitMarginPct | Float | Profit margin percentage calculated from benefit and sales |
| profitCategory | String | Data-driven category: High Margin (>15%), Medium (5-15%), Low (0-5%), Loss (<0%) |
| deliveryDelay | Integer | Days between scheduled and actual delivery (negative = early) |
| orderYear | Integer | Extracted year from order date |
| orderMonth | Integer | Extracted month (1-12) from order date |
| orderQuarter | String | Quarter (Q1-Q4) from order date |
| orderDayOfWeek | String | Day name (Monday-Sunday) from order date |
| orderHour | Integer | Hour of day (0-23) from order date |
| isLate | Integer | Binary flag: 1 if late, 0 otherwise |

---

## ➕ Added Fields: Clickstream Events

These fields were added to support session analysis, conversion tracking, and temporal behavior patterns for funnel optimization.

| Field Name | Type | Description |
|------------|------|-------------|
| eventYear | Integer | Extracted year from event timestamp |
| eventMonth | Integer | Extracted month (1-12) from event timestamp |
| eventQuarter | String | Quarter (Q1-Q4) from event timestamp |
| eventDayOfWeek | String | Day name (Monday-Sunday) from event timestamp |
| eventHourOfDay | Integer | Hour of day (0-23) from event timestamp |
| isCartAdd | Integer | Binary flag: 1 if cart addition, 0 if page view |
| eventType | String | "Cart Add" or "Page View" (parsed from URL) |
| sessionDate | Date | Date only (without time) for daily aggregations |
| pageType | String | "Product", "Category", or "Department" based on URL pattern |
| sessionID | String | Concatenated user identifier for session tracking |
| isWeekend | Integer | Binary flag: 1 if Saturday/Sunday, 0 otherwise |
| timeOfDay | String | "Morning" (6-12), "Afternoon" (12-18), "Evening" (18-22), "Night" (22-6) |

---

## 🔧 Transformation Details

All data cleansing and enrichment was performed using **Alteryx Designer Cloud**. For detailed workflows including:
- Tool configurations and connections
- Formula expressions for calculated fields
- Data cleansing steps (trimming, case standardization)
- Data type conversions and validations

**See:** `alteryxWorkflows/` folder for complete transformation formulas (JSON) and process documentation.

---

**Pipeline Flow:**  
`S3 Raw` → `Alteryx Transformation` → `S3 Processed` → `Snowflake` → `dbt` → `Sigma`

These processed files serve as the clean foundation for downstream analytics and reporting.

