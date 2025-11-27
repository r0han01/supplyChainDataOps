# Data Fetcher

Automated pipeline to download DataCo Supply Chain dataset from Kaggle and upload to S3.

## What It Does

- Downloads 3 datasets from Kaggle (180K orders + 470K clickstream events)
- Uploads raw CSV files to S3 bucket
- Cleans up any old files before uploading new ones

## Why Kaggle?

Kaggle is the only source with automated API access. The dataset is public and well-maintained.

**Alternative manual sources if needed:**
- **GitHub:** [shashwatwork/supply-chain-data](https://github.com/shashwatwork) (clone + extract)
- **Mendeley:** https://data.mendeley.com/datasets/8gx2fvg2k6/5 (direct download, user-friendly)

## Setup

Get your Kaggle API token:
```bash
export KAGGLE_API_TOKEN="your_token_here"
```

## Usage

**Default:** Upload to S3
```bash
python dataFetcher.py
```

**Save locally:** Use `--local-path` or `-p`
```bash
python dataFetcher.py --local-path localData    # Save to localData folder
python dataFetcher.py -p .                     # Save to current directory
```

## About File Format

Originally wanted to use Parquet (better compression, faster queries). Switched to CSV because Alteryx Designer Cloud doesn't support Parquet preview. CSV works fine for our pipeline and keeps things simple.

## Output

Files go to: `s3://dataco-supply-chain-analytics/raw/`

- DataCoSupplyChainDataset.csv (~96 MB)
- DescriptionDataCoSupplyChain.csv (~4 KB)
- tokenized_access_logs.csv (~92 MB)

Total raw data: ~190 MB

