-- ============================================================================
-- Snowflake Manual Data Ingestion
-- ============================================================================
-- Run these commands in Snowflake UI (Worksheets) to manually load data
-- from S3 into Snowflake tables.
--
-- Prerequisites:
--   1. Terraform setup completed (AWS IAM role and Snowflake storage integration)
--   2. Processed data files available in S3: processed/DataCoSupplyChainDataset/
--      and processed/clickstreamDataPreparation/
-- ============================================================================

-- Set context
USE WAREHOUSE COMPUTE_WH;
USE DATABASE SUPPLYCHAINDB;
USE SCHEMA RAWDATA;

-- Create file formats for CSV parsing
CREATE FILE FORMAT IF NOT EXISTS SUPPLYCHAINDB.RAWDATA.csv_format
    TYPE = CSV
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    SKIP_HEADER = 1
    DATE_FORMAT = 'MM/DD/YYYY HH24:MI'
    TIMESTAMP_FORMAT = 'MM/DD/YYYY HH24:MI';

CREATE FILE FORMAT IF NOT EXISTS SUPPLYCHAINDB.RAWDATA.csv_format_clickstream
    TYPE = CSV
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    SKIP_HEADER = 1
    DATE_FORMAT = 'YYYY-MM-DD'
    TIMESTAMP_FORMAT = 'MM/DD/YYYY HH24:MI';

-- Create Supply Chain Orders table
CREATE TABLE IF NOT EXISTS SUPPLYCHAINDB.RAWDATA.dataCoSupplyChainOrders (
    "Type" VARCHAR(50),
    "Days for shipping (real)" INT,
    "Days for shipment (scheduled)" INT,
    "Benefit per order" FLOAT,
    "Sales per customer" FLOAT,
    "Delivery Status" VARCHAR(50),
    "Late_delivery_risk" INT,
    "Category Id" INT,
    "Category Name" VARCHAR(100),
    "Customer City" VARCHAR(100),
    "Customer Country" VARCHAR(100),
    "Customer Fname" VARCHAR(100),
    "Customer Id" INT,
    "Customer Lname" VARCHAR(100),
    "Customer Segment" VARCHAR(50),
    "Customer State" VARCHAR(100),
    "Customer Street" VARCHAR(200),
    "Customer Zipcode" VARCHAR(20),
    "Department Id" INT,
    "Department Name" VARCHAR(100),
    "Latitude" FLOAT,
    "Longitude" FLOAT,
    "Market" VARCHAR(50),
    "Order City" VARCHAR(100),
    "Order Country" VARCHAR(100),
    "Order Customer Id" INT,
    "order date (DateOrders)" TIMESTAMP_NTZ,
    "Order Id" INT,
    "Order Item Cardprod Id" INT,
    "Order Item Discount" FLOAT,
    "Order Item Discount Rate" FLOAT,
    "Order Item Id" INT,
    "Order Item Product Price" FLOAT,
    "Order Item Profit Ratio" FLOAT,
    "Order Item Quantity" INT,
    "Sales" FLOAT,
    "Order Item Total" FLOAT,
    "Order Profit Per Order" FLOAT,
    "Order Region" VARCHAR(50),
    "Order State" VARCHAR(100),
    "Order Status" VARCHAR(50),
    "Order Zipcode" VARCHAR(20),
    "Product Card Id" INT,
    "Product Category Id" INT,
    "Product Image" VARCHAR(200),
    "Product Name" VARCHAR(200),
    "Product Price" FLOAT,
    "shipping date (DateOrders)" TIMESTAMP_NTZ,
    "Shipping Mode" VARCHAR(50),
    profitMarginPct FLOAT,
    profitCategory VARCHAR(50),
    deliveryDelay INT,
    orderYear INT,
    orderMonth INT,
    orderQuarter VARCHAR(10),
    orderDayOfWeek VARCHAR(20),
    orderHour INT,
    isLate INT
);

-- Create Clickstream Events table
CREATE TABLE IF NOT EXISTS SUPPLYCHAINDB.RAWDATA.clickstreamEvents (
    "Product" VARCHAR(200),
    "Category" VARCHAR(100),
    "Date" TIMESTAMP_NTZ,
    "Month" VARCHAR(10),
    "Hour" INT,
    "Department" VARCHAR(100),
    "ip" VARCHAR(50),
    "url" VARCHAR(500),
    eventYear INT,
    eventMonth INT,
    eventQuarter VARCHAR(10),
    eventDayOfWeek VARCHAR(20),
    eventHourOfDay INT,
    isCartAdd VARCHAR(10),
    eventType VARCHAR(50),
    sessionDate DATE,
    pageType VARCHAR(50),
    sessionID VARCHAR(200),
    isWeekend VARCHAR(10),
    timeOfDay VARCHAR(20)
);

-- Load Supply Chain Orders from S3
COPY INTO SUPPLYCHAINDB.RAWDATA.dataCoSupplyChainOrders
FROM 's3://dataco-supply-chain-analytics/processed/DataCoSupplyChainDataset/DataCoSupplyChainDataset.csv'
STORAGE_INTEGRATION = supplyChainS3Integration
FILE_FORMAT = SUPPLYCHAINDB.RAWDATA.csv_format
ON_ERROR = 'CONTINUE';

-- Load Clickstream Events from S3
COPY INTO SUPPLYCHAINDB.RAWDATA.clickstreamEvents
FROM 's3://dataco-supply-chain-analytics/processed/clickstreamDataPreparation/clickstreamDataPreparation.csv'
STORAGE_INTEGRATION = supplyChainS3Integration
FILE_FORMAT = SUPPLYCHAINDB.RAWDATA.csv_format_clickstream
ON_ERROR = 'CONTINUE';

-- Verify data loaded
SELECT 
    'Orders' AS table_name,
    COUNT(*) AS row_count
FROM SUPPLYCHAINDB.RAWDATA.dataCoSupplyChainOrders
UNION ALL
SELECT 
    'Clickstream' AS table_name,
    COUNT(*) AS row_count
FROM SUPPLYCHAINDB.RAWDATA.clickstreamEvents;

-- Sample queries to verify data
SELECT 
    "Order Id",
    "Product Name",
    profitMarginPct,
    profitCategory
FROM SUPPLYCHAINDB.RAWDATA.dataCoSupplyChainOrders
LIMIT 10;

SELECT 
    "Product",
    eventType,
    sessionID,
    timeOfDay
FROM SUPPLYCHAINDB.RAWDATA.clickstreamEvents
LIMIT 10;

