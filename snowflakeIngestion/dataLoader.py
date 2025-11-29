#!/usr/bin/env python3
"""
Snowflake Data Loader
Loads processed data from S3 into Snowflake tables using COPY INTO commands.
"""
import os
import sys
import re

try:
    import snowflake.connector
except ImportError:
    print("❌ snowflake-connector-python not installed")
    print("   Install: pip install snowflake-connector-python")
    sys.exit(1)


def to_camel_case(name):
    """Convert column name to camelCase"""
    # Remove quotes and spaces, convert to camelCase
    name = name.strip('"').strip()
    # Split by spaces and special characters
    parts = re.split(r'[\s_()]+', name)
    # First part lowercase, rest capitalize
    camel = parts[0].lower() + ''.join(word.capitalize() for word in parts[1:] if word)
    return camel


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
        """Create supply chain orders table with camelCase columns"""
        cursor = conn.cursor()
        sql = f"""
        CREATE TABLE IF NOT EXISTS {self.database}.{self.schema}.dataCoSupplyChainOrders (
            type VARCHAR(50),
            daysForShippingReal INT,
            daysForShipmentScheduled INT,
            benefitPerOrder FLOAT,
            salesPerCustomer FLOAT,
            deliveryStatus VARCHAR(50),
            lateDeliveryRisk INT,
            categoryId INT,
            categoryName VARCHAR(100),
            customerCity VARCHAR(100),
            customerCountry VARCHAR(100),
            customerFname VARCHAR(100),
            customerId INT,
            customerLname VARCHAR(100),
            customerSegment VARCHAR(50),
            customerState VARCHAR(100),
            customerStreet VARCHAR(200),
            customerZipcode VARCHAR(20),
            departmentId INT,
            departmentName VARCHAR(100),
            latitude FLOAT,
            longitude FLOAT,
            market VARCHAR(50),
            orderCity VARCHAR(100),
            orderCountry VARCHAR(100),
            orderCustomerId INT,
            orderDate TIMESTAMP_NTZ,
            orderId INT,
            orderItemCardprodId INT,
            orderItemDiscount FLOAT,
            orderItemDiscountRate FLOAT,
            orderItemId INT,
            orderItemProductPrice FLOAT,
            orderItemProfitRatio FLOAT,
            orderItemQuantity INT,
            sales FLOAT,
            orderItemTotal FLOAT,
            orderProfitPerOrder FLOAT,
            orderRegion VARCHAR(50),
            orderState VARCHAR(100),
            orderStatus VARCHAR(50),
            orderZipcode VARCHAR(20),
            productCardId INT,
            productCategoryId INT,
            productImage VARCHAR(200),
            productName VARCHAR(200),
            productPrice FLOAT,
            shippingDate TIMESTAMP_NTZ,
            shippingMode VARCHAR(50),
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
        """Create clickstream events table with camelCase columns"""
        cursor = conn.cursor()
        sql = f"""
        CREATE TABLE IF NOT EXISTS {self.database}.{self.schema}.clickstreamEvents (
            product VARCHAR(200),
            category VARCHAR(100),
            date TIMESTAMP_NTZ,
            month VARCHAR(10),
            hour INT,
            department VARCHAR(100),
            ip VARCHAR(50),
            url VARCHAR(500),
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
        """Load data from S3 into Snowflake table with column mapping"""
        cursor = conn.cursor()
        
        # Use COPY INTO with explicit column mapping
        # Snowflake maps CSV columns by position to table columns
        if table_name == "dataCoSupplyChainOrders":
            sql = f"""
            COPY INTO {self.database}.{self.schema}.{table_name}
            (type, daysForShippingReal, daysForShipmentScheduled, benefitPerOrder, salesPerCustomer,
             deliveryStatus, lateDeliveryRisk, categoryId, categoryName, customerCity, customerCountry,
             customerFname, customerId, customerLname, customerSegment, customerState, customerStreet,
             customerZipcode, departmentId, departmentName, latitude, longitude, market, orderCity,
             orderCountry, orderCustomerId, orderDate, orderId, orderItemCardprodId, orderItemDiscount,
             orderItemDiscountRate, orderItemId, orderItemProductPrice, orderItemProfitRatio,
             orderItemQuantity, sales, orderItemTotal, orderProfitPerOrder, orderRegion, orderState,
             orderStatus, orderZipcode, productCardId, productCategoryId, productImage, productName,
             productPrice, shippingDate, shippingMode, profitMarginPct, profitCategory, deliveryDelay,
             orderYear, orderMonth, orderQuarter, orderDayOfWeek, orderHour, isLate)
            FROM 's3://{self.s3_bucket}/{self.s3_prefix}{s3_file}'
            STORAGE_INTEGRATION = {self.storage_integration}
            FILE_FORMAT = {file_format_name}
            ON_ERROR = 'CONTINUE';
            """
        else:  # clickstreamEvents
            sql = f"""
            COPY INTO {self.database}.{self.schema}.{table_name}
            (product, category, date, month, hour, department, ip, url, eventYear, eventMonth,
             eventQuarter, eventDayOfWeek, eventHourOfDay, isCartAdd, eventType, sessionDate,
             pageType, sessionID, isWeekend, timeOfDay)
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
