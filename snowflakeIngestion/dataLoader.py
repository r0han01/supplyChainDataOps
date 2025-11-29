#!/usr/bin/env python3
"""
Snowflake Data Loader
Loads processed data from S3 into Snowflake tables using COPY INTO commands.
"""
import os
import sys

try:
    import snowflake.connector
except ImportError:
    print("❌ snowflake-connector-python not installed")
    print("   Install: pip install snowflake-connector-python")
    sys.exit(1)


class SnowflakeDataLoader:
    """Load data from S3 to Snowflake tables"""

    def __init__(self):
        self.account = os.getenv('SNOWFLAKE_ACCOUNT')
        self.user = os.getenv('SNOWFLAKE_USER')
        self.password = os.getenv('SNOWFLAKE_PASSWORD')
        self.warehouse = os.getenv('SNOWFLAKE_WAREHOUSE', 'COMPUTE_WH')
        self.database = os.getenv('SNOWFLAKE_DATABASE', 'SUPPLYCHAINDB')
        self.schema = os.getenv('SNOWFLAKE_SCHEMA', 'RAWDATA')
        self.storage_integration = os.getenv('SNOWFLAKE_STORAGE_INTEGRATION', 'supplyChainS3Integration')
        self.s3_bucket = os.getenv('S3_BUCKET_NAME', 'dataco-supply-chain-analytics')
        self.s3_prefix = os.getenv('S3_PROCESSED_PREFIX', 'processed/')

        if not all([self.account, self.user, self.password]):
            raise ValueError("SNOWFLAKE_ACCOUNT, SNOWFLAKE_USER, SNOWFLAKE_PASSWORD required")

    def _get_connection(self):
        """Create Snowflake connection"""
        return snowflake.connector.connect(
            user=self.user,
            password=self.password,
            account=self.account,
            warehouse=self.warehouse
        )

    def _ensure_database_schema(self, conn):
        """Create database and schema if they don't exist"""
        cursor = conn.cursor()
        try:
            cursor.execute(f"CREATE DATABASE IF NOT EXISTS {self.database}")
            cursor.execute(f"USE DATABASE {self.database}")
            cursor.execute(f"CREATE SCHEMA IF NOT EXISTS {self.schema}")
            cursor.execute(f"USE SCHEMA {self.schema}")
        except Exception as e:
            raise RuntimeError(f"Failed to create database/schema: {e}")
        finally:
            cursor.close()

    def _create_file_format(self, conn, format_name, date_format, timestamp_format):
        """Create file format for CSV parsing"""
        cursor = conn.cursor()
        try:
            sql = f"""
            CREATE FILE FORMAT IF NOT EXISTS {format_name}
            TYPE = CSV
            FIELD_OPTIONALLY_ENCLOSED_BY = '"'
            SKIP_HEADER = 1
            DATE_FORMAT = '{date_format}'
            TIMESTAMP_FORMAT = '{timestamp_format}';
            """
            cursor.execute(sql)
        finally:
            cursor.close()

    def _create_orders_table(self, conn):
        """Create supply chain orders table"""
        cursor = conn.cursor()
        sql = f"""
        CREATE TABLE IF NOT EXISTS {self.database}.{self.schema}.dataCoSupplyChainOrders (
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
        """
        try:
            cursor.execute(sql)
        finally:
            cursor.close()

    def _create_clickstream_table(self, conn):
        """Create clickstream events table"""
        cursor = conn.cursor()
        sql = f"""
        CREATE TABLE IF NOT EXISTS {self.database}.{self.schema}.clickstreamEvents (
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
        """
        try:
            cursor.execute(sql)
        finally:
            cursor.close()

    def _load_from_s3(self, conn, table_name, s3_file, file_format_name):
        """Load data from S3 into Snowflake table"""
        cursor = conn.cursor()
        sql = f"""
        COPY INTO {self.database}.{self.schema}.{table_name}
        FROM 's3://{self.s3_bucket}/{self.s3_prefix}{s3_file}'
        STORAGE_INTEGRATION = {self.storage_integration}
        FILE_FORMAT = {file_format_name}
        ON_ERROR = 'CONTINUE';
        """
        try:
            cursor.execute(sql)
            results = cursor.fetchall()
            rows_loaded = sum(
                int(row[1]) for row in results
                if len(row) > 1 and row[1] and str(row[1]).isdigit()
            )
            return rows_loaded
        finally:
            cursor.close()

    def _get_row_count(self, conn, table_name):
        """Get row count for a table"""
        cursor = conn.cursor()
        try:
            cursor.execute(f"SELECT COUNT(*) FROM {self.database}.{self.schema}.{table_name}")
            return cursor.fetchone()[0]
        finally:
            cursor.close()

    def run(self):
        """Execute complete data loading process"""
        conn = None
        try:
            conn = self._get_connection()
            self._ensure_database_schema(conn)

            self._create_file_format(
                conn,
                f"{self.database}.{self.schema}.csv_format",
                "MM/DD/YYYY HH24:MI",
                "MM/DD/YYYY HH24:MI"
            )
            self._create_file_format(
                conn,
                f"{self.database}.{self.schema}.csv_format_clickstream",
                "YYYY-MM-DD",
                "MM/DD/YYYY HH24:MI"
            )

            self._create_orders_table(conn)
            self._create_clickstream_table(conn)

            orders_rows = self._load_from_s3(
                conn,
                "dataCoSupplyChainOrders",
                "DataCoSupplyChainDataset/DataCoSupplyChainDataset.csv",
                f"{self.database}.{self.schema}.csv_format"
            )

            clickstream_rows = self._load_from_s3(
                conn,
                "clickstreamEvents",
                "clickstreamDataPreparation/clickstreamDataPreparation.csv",
                f"{self.database}.{self.schema}.csv_format_clickstream"
            )

            orders_count = self._get_row_count(conn, "dataCoSupplyChainOrders")
            clickstream_count = self._get_row_count(conn, "clickstreamEvents")

            return {
                'orders_loaded': orders_rows,
                'clickstream_loaded': clickstream_rows,
                'orders_total': orders_count,
                'clickstream_total': clickstream_count,
                'success': True
            }

        except Exception as e:
            return {'success': False, 'error': str(e)}
        finally:
            if conn:
                conn.close()


if __name__ == "__main__":
    loader = SnowflakeDataLoader()
    result = loader.run()
    
    if result.get('success'):
        print(f"✅ Orders: {result['orders_loaded']:,} loaded, {result['orders_total']:,} total")
        print(f"✅ Clickstream: {result['clickstream_loaded']:,} loaded, {result['clickstream_total']:,} total")
        sys.exit(0)
    else:
        print(f"❌ Error: {result.get('error', 'Unknown error')}")
        sys.exit(1)
