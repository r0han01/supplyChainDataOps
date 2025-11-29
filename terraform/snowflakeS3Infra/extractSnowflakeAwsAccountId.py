#!/usr/bin/env python3
"""
Extract Snowflake AWS Account ID from Storage Integration

Connects to Snowflake and extracts the AWS account ID embedded in the
storage integration's IAM user ARN. This is useful when documentation
shows generic account IDs that don't match your actual Snowflake account.
"""
import os
import re
import sys

try:
    import snowflake.connector
except ImportError:
    print("❌ snowflake-connector-python not installed")
    print("   Install: pip install snowflake-connector-python")
    sys.exit(1)


def extract_account_id():
    """Extract AWS account ID from Snowflake storage integration IAM user ARN."""
    account = os.getenv('SNOWFLAKE_ACCOUNT')
    user = os.getenv('SNOWFLAKE_USER')
    password = os.getenv('SNOWFLAKE_PASSWORD')
    warehouse = os.getenv('SNOWFLAKE_WAREHOUSE', 'COMPUTE_WH')
    database = os.getenv('SNOWFLAKE_DATABASE', 'SUPPLYCHAINDB')
    integration = os.getenv('SNOWFLAKE_STORAGE_INTEGRATION', 'supplyChainS3Integration')

    if not all([account, user, password]):
        print("❌ Required environment variables: SNOWFLAKE_ACCOUNT, SNOWFLAKE_USER, SNOWFLAKE_PASSWORD")
        return None

    try:
        conn = snowflake.connector.connect(
            user=user,
            password=password,
            account=account,
            warehouse=warehouse,
            database=database
        )
        cursor = conn.cursor()

        cursor.execute(f"DESC STORAGE INTEGRATION {integration}")
        results = cursor.fetchall()

        iam_user_arn = None
        external_id = None

        print(f"\n📋 Storage Integration: {integration}")
        print("-" * 60)
        for row in results:
            prop_name, _, prop_value = row[0], row[1], row[2]
            print(f"  {prop_name}: {prop_value}")

            if prop_name == 'STORAGE_AWS_IAM_USER_ARN':
                iam_user_arn = prop_value
            elif prop_name == 'STORAGE_AWS_EXTERNAL_ID':
                external_id = prop_value
        print("-" * 60)

        if iam_user_arn:
            match = re.search(r'arn:aws:iam::(\d{12}):user/', iam_user_arn)
            if match:
                account_id = match.group(1)
                print(f"\n✅ IAM User ARN: {iam_user_arn}")
                print(f"✅ External ID: {external_id}")
                print(f"✅ AWS Account ID: {account_id}\n")
                return account_id
            else:
                print(f"❌ Could not extract account ID from ARN")
        else:
            print(f"❌ STORAGE_AWS_IAM_USER_ARN not found")
            print(f"   Verify: DESC STORAGE INTEGRATION {integration};")

        cursor.close()
        conn.close()

    except Exception as e:
        print(f"❌ Error: {e}")
        return None


if __name__ == "__main__":
    extract_account_id()
