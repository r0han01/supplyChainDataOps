"""
DataCo Supply Chain Dataset Fetcher
Automated data pipeline: Kaggle → S3 (or local directory)
"""

import os
import shutil
import logging
import argparse
from pathlib import Path
from datetime import datetime
import boto3
from botocore.exceptions import ClientError

logging.basicConfig(level=logging.INFO, format='%(message)s')
logger = logging.getLogger(__name__)


class DataFetcher:
    """Fetch and upload DataCo supply chain dataset to S3"""
    
    DATASET_NAME = "shashwatwork/dataco-smart-supply-chain-for-big-data-analysis"
    BUCKET_NAME = "dataco-supply-chain-analytics"
    REQUIRED_FILES = [
        "DataCoSupplyChainDataset.csv",
        "DescriptionDataCoSupplyChain.csv",
        "tokenized_access_logs.csv"
    ]
    
    def __init__(self, bucket_name=None, local_cache="cache"):
        self.bucket_name = bucket_name or self.BUCKET_NAME
        self.local_cache = Path(local_cache).resolve()
        self.local_cache.mkdir(parents=True, exist_ok=True)
        self.s3_client = boto3.client('s3')
    
    def _validate_kaggle_token(self):
        if not os.environ.get('KAGGLE_API_TOKEN'):
            raise EnvironmentError("KAGGLE_API_TOKEN environment variable not set")
    
    def _ensure_bucket(self):
        try:
            self.s3_client.head_bucket(Bucket=self.bucket_name)
        except ClientError as e:
            if e.response['Error']['Code'] == '404':
                region = boto3.session.Session().region_name or 'us-east-1'
                config = {} if region == 'us-east-1' else {
                    'CreateBucketConfiguration': {'LocationConstraint': region}
                }
                self.s3_client.create_bucket(Bucket=self.bucket_name, **config)
    
    def download_dataset(self):
        """Download dataset from Kaggle to local cache"""
        self._validate_kaggle_token()
        
        try:
            import kagglehub
        except ImportError:
            raise ImportError("kagglehub not installed: pip install kagglehub")
        
        cache_path = kagglehub.dataset_download(self.DATASET_NAME)
        
        for filename in self.REQUIRED_FILES:
            src = Path(cache_path) / filename
            dst = self.local_cache / filename
            if src.exists():
                shutil.copy2(src, dst)
        
        return True
    
    def upload_to_s3(self, prefix="raw"):
        """Upload files to S3"""
        self._ensure_bucket()
        
        uploaded = []
        for filename in self.REQUIRED_FILES:
            local_path = self.local_cache / filename
            if not local_path.exists():
                continue
            
            s3_key = f"{prefix}/{filename}"
            
            try:
                self.s3_client.upload_file(
                    str(local_path),
                    self.bucket_name,
                    s3_key,
                    ExtraArgs={'ServerSideEncryption': 'AES256'}
                )
                uploaded.append(s3_key)
            except ClientError:
                continue
        
        return uploaded
    
    def clean_s3_prefix(self, prefix):
        """Remove all objects under S3 prefix"""
        try:
            response = self.s3_client.list_objects_v2(
                Bucket=self.bucket_name,
                Prefix=prefix
            )
            
            if 'Contents' in response:
                objects = [{'Key': obj['Key']} for obj in response['Contents']]
                self.s3_client.delete_objects(
                    Bucket=self.bucket_name,
                    Delete={'Objects': objects}
                )
        except ClientError:
            pass
    
    def save_to_local(self, local_path):
        """Copy files to local directory"""
        destination = Path(local_path).resolve()
        destination.mkdir(parents=True, exist_ok=True)
        
        saved = []
        for filename in self.REQUIRED_FILES:
            src = self.local_cache / filename
            dst = destination / filename
            if src.exists():
                shutil.copy2(src, dst)
                saved.append(str(dst))
        
        return saved
    
    def run(self, clean_existing=True, local_path=None):
        """Execute complete pipeline"""
        logger.info(f"Fetching: {self.DATASET_NAME}")
        
        self.download_dataset()
        logger.info("Downloaded")
        
        if local_path:
            # Save to local directory
            saved = self.save_to_local(local_path)
            logger.info(f"Saved to: {local_path} ({len(saved)} files)")
            return saved
        else:
            # Upload to S3 (default behavior)
            if clean_existing:
                self.clean_s3_prefix("raw")
            
            uploaded = self.upload_to_s3(prefix="raw")
            logger.info(f"Uploaded: s3://{self.bucket_name}/raw/ ({len(uploaded)} files)")
            return uploaded


def main():
    parser = argparse.ArgumentParser(
        description='Fetch DataCo supply chain dataset from Kaggle',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python dataFetcher.py                    # Upload to S3 (default)
  python dataFetcher.py --local-path .     # Save to current directory
  python dataFetcher.py -p localData       # Save to localData folder
        """
    )
    parser.add_argument(
        '-p', '--local-path',
        type=str,
        default=None,
        help='Save files to local directory instead of S3 (default: None, uploads to S3)'
    )
    
    args = parser.parse_args()
    
    fetcher = DataFetcher()
    fetcher.run(local_path=args.local_path)
    return 0


if __name__ == "__main__":
    import sys
    sys.exit(main())
