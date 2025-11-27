# Raw Data (Reference Only)

This folder contains **sample data** (15 rows each) from the original datasets for reference purposes. The full datasets (~190 MB) are stored in `localData/` (gitignored) and on S3.

---

## 📦 Datasets Overview

### 1. DataCoSupplyChainDataset.csv
**180,519 orders** from DataCo Global's supply chain operations across clothing, sports, and electronics categories.

### 2. tokenized_access_logs.csv
**470,564 clickstream events** capturing customer behavior on the e-commerce platform (page views and cart additions).

---

## 📊 Dataset 1: Supply Chain Orders

**File:** `DataCoSupplyChainDataset.csv`  
**Rows:** 180,519 | **Columns:** 53

| Column Name | Description |
|-------------|-------------|
| Type | Type of transaction |
| Days for shipping (real) | Actual days taken for shipping |
| Days for shipment (scheduled) | Scheduled days for shipping |
| Benefit per order | Profit generated per order |
| Sales per customer | Total sales amount per customer |
| Delivery Status | Current status of delivery (e.g., Late delivery, Shipping on time, Advance shipping, Shipping canceled) |
| Late_delivery_risk | Binary flag indicating risk of late delivery (0 or 1) |
| Category Id | Unique identifier for product category |
| Category Name | Name of product category |
| Customer City | City where customer is located |
| Customer Country | Country where customer is located |
| Customer Fname | Customer's first name |
| Customer Id | Unique customer identifier |
| Customer Lname | Customer's last name |
| Customer Segment | Market segment of customer (e.g., Consumer, Corporate, Home Office) |
| Customer State | State where customer is located |
| Customer Street | Street address of customer |
| Customer Zipcode | Postal code of customer |
| Department Id | Unique identifier for department |
| Department Name | Name of department handling the order |
| Latitude | Geographic latitude of customer location |
| Longitude | Geographic longitude of customer location |
| Market | Geographic market region (e.g., LATAM, USCA, Europe, Africa) |
| Order City | City where order was placed |
| Order Country | Country where order was placed |
| Order Customer Id | Customer ID associated with the order |
| order date (DateOrders) | Date and time when order was placed |
| Order Id | Unique order identifier |
| Order Item Cardprod Id | Card product ID for order item |
| Order Item Discount | Discount amount applied to order item |
| Order Item Discount Rate | Discount rate (percentage) applied |
| Order Item Id | Unique identifier for order item |
| Order Item Product Price | Price of product in order item |
| Order Item Profit Ratio | Profit ratio for the order item |
| Order Item Quantity | Quantity of items ordered |
| Sales | Total sales amount for the order |
| Order Item Total | Total amount for the order item |
| Order Profit Per Order | Total profit generated from the order |
| Order Region | Geographic region of the order |
| Order State | State where order was placed |
| Order Status | Current status of the order (e.g., COMPLETE, PENDING, CANCELED) |
| Order Zipcode | Postal code where order was placed |
| Product Card Id | Card identifier for the product |
| Product Category Id | Category ID of the product |
| Product Image | URL or path to product image |
| Product Name | Name of the product |
| Product Price | Price of the product |
| shipping date (DateOrders) | Date and time when shipment was dispatched |
| Shipping Mode | Method of shipping (e.g., Standard Class, First Class, Second Class, Same Day) |

### 🔎 Key Findings

This dataset captures 180,519 orders distributed across 5 global markets, with LATAM leading at 28.6%, followed by Europe (27.8%) and Pacific Asia (22.9%). A striking concentration appears in Caguas with 66,770 orders (37% of total), while the remaining orders spread across just one other country. Delivery performance reveals a critical operational issue: 54.8% of orders trigger late delivery risk flags, with 98,977 orders actually delivered late versus only 32,196 on time.

The financial picture shows substantial variance, with profit per order ranging from -$4,274.98 to +$911.80. Notably, 33,784 orders (18.7%) are loss-making, indicating pricing or operational inefficiencies. Sales per customer span from $7.49 to $1,939.99, suggesting a mix of individual buyers and potential bulk purchasers. The product catalog includes 50 distinct categories, with Cleats (24,551 orders), Men's Footwear (22,246), and Women's Apparel (21,035) as top performers. Customer distribution leans heavily toward Consumers (93,504) compared to Corporate (54,789) and Home Office (32,226) segments, with Standard Class shipping (107,752 orders) dominating fulfillment methods.

---

## 📊 Dataset 2: Clickstream Events

**File:** `tokenized_access_logs.csv`  
**Rows:** 470,564 | **Columns:** 8

| Column Name | Description |
|-------------|-------------|
| Product | Product name or identifier that was viewed/interacted with |
| Category | Product category (e.g., Sporting Goods, Cleats, Men's Footwear) |
| Date | Timestamp of the event (format: M/D/YYYY H:MM) |
| Month | Numeric month when event occurred (1-12) |
| Hour | Hour of day when event occurred (0-23) |
| Department | Department category of the product |
| ip | Tokenized/anonymized IP address of the user |
| url | URL path of the page accessed, indicates event type:<br>• Paths containing "cart" = Cart addition events<br>• Other paths = Page view events |

### 🔎 Key Findings

This dataset contains 469,977 clickstream events tracked across 5 months (September through January), with September showing peak activity at 137,238 events. The event mix reveals a 29.5% conversion intent rate, with 138,844 cart-related actions versus 331,133 page views. User activity peaks during evening hours, with hour 21 (9 PM) recording the highest traffic at 30,749 events, followed by hours 20 and 22, suggesting a primarily evening-browsing user base.

The tracking system captures 3,340 unique tokenized IP addresses, enabling session analysis while maintaining privacy compliance. Product engagement spans 33 distinct categories across 6 departments, with cleats (27,878 events), shop by sport (26,227), and featured shops (26,200) driving the most interactions. Notably, top categories align with the supply chain order data, confirming that browsing behavior translates to actual purchases. The URL structure embedded in the dataset allows for reconstruction of user journey paths, distinguishing between discovery-phase browsing and high-intent cart additions, making this particularly valuable for funnel analysis when combined with the orders dataset.

---

## 🔍 Data Quality Observations

The supply chain dataset exhibits several quality issues that could impact analysis accuracy. Text fields show inconsistent casing patterns in delivery status and product names, while leading and trailing whitespace appears throughout categorical columns, potentially causing grouping problems. The 18.7% of orders showing negative profit values signal pricing or cost issues that require careful interpretation. Date/time fields lack standardization, making temporal analysis cumbersome, and there's no built-in way to quickly segment orders by profitability or calculate margin percentages.

The clickstream dataset presents its own challenges, primarily around temporal and behavioral tracking. Timestamps combine date and time in a single field, making hour-based or day-based filtering difficult. Event types are buried within URL strings rather than explicitly flagged, requiring pattern matching to distinguish page views from cart additions. There's no native session identifier to track user journeys, and temporal context like weekday versus weekend or time-of-day categories is absent. The lack of page type classification makes it hard to understand whether users are browsing departments, categories, or specific products.

Both datasets would benefit from enrichment fields that support deeper analysis—things like profit categories, delivery delay calculations, temporal breakdowns, session tracking, and event type flags would make the data far more accessible for business intelligence work.

---

## 🛠️ Why Alteryx?

We chose Alteryx Designer Cloud for initial data preparation because it handles exactly the kind of cleansing and enrichment these datasets need—trimming whitespace, standardizing casing, parsing dates, and creating calculated fields—all through an intuitive visual interface. More importantly, Alteryx integrates seamlessly into our pipeline architecture: it can read directly from S3 where our raw data lands, perform transformations, and write processed outputs back to S3 for downstream consumption by Snowflake and dbt. This makes it perfect for the early-stage data prep layer where we need quick profiling, cleaning, and row-level enrichment before the data enters the warehouse for complex analytics. The workflows are reproducible, versionable, and easy to maintain as the pipeline evolves.

---

## 📂 Next Steps

This project uses **S3 as the central data lake** for pipeline storage. The `dataFetcher` module automatically downloads raw datasets from Kaggle and uploads them to `s3://dataco-supply-chain-analytics/raw/`, establishing the foundation for our data pipeline. From there, Alteryx reads these raw files, applies transformations, and writes cleaned outputs to `s3://dataco-supply-chain-analytics/processed/`.

To see the transformation details:
- **Alteryx workflows:** Check the `alteryxWorkflows/` folder for formulas and process documentation
- **Sample outputs:** Browse `processedData (reference only)/` for examples of transformed data
- **Full processed files:** Available at `s3://dataco-supply-chain-analytics/processed/`

---

**Note:** These sample files are for schema reference only. Full datasets are available:
- **S3 Raw:** `s3://dataco-supply-chain-analytics/raw/` (default: `python dataFetcher.py`)
- **S3 Processed:** `s3://dataco-supply-chain-analytics/processed/` (Alteryx output)
- **Locally (optional):** Run `python dataFetcher.py --local-path localData` to save to local directory

