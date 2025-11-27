#!/bin/bash

set -e

echo "🚀 DataCo Supply Chain Analytics - Setup"
echo "========================================"

# Check if .env file exists
if [ ! -f .env ]; then
    echo "⚠️  .env file not found. Creating from .env.example..."
    cp .env.example .env
    echo "✅ Created .env file. Please update it with your credentials."
    echo ""
    echo "Required:"
    echo "  - KAGGLE_API_TOKEN (get from https://www.kaggle.com/settings/account)"
    echo "  - AWS credentials (configure via 'aws configure')"
    echo ""
    exit 1
fi

# Load environment variables
source .env

# Check Python version
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is required but not installed."
    exit 1
fi

echo "✓ Python 3 found"

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "📦 Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
source venv/bin/activate

# Install dependencies
echo "📦 Installing dependencies..."
pip install -q --upgrade pip
pip install -q -r requirements.txt

echo "✅ Dependencies installed"

# Create necessary directories
mkdir -p localData
echo "✅ Created localData directory for dataset downloads"

# Verify AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    echo "⚠️  AWS credentials not configured. Run 'aws configure' first."
    exit 1
fi

echo "✅ AWS credentials verified"

# Run data fetcher
echo ""
echo "📥 Fetching data from Kaggle..."
python dataFetcher/dataFetcher.py

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Open Alteryx Designer Cloud"
echo "  2. Run workflow: ordersDataPreparation"
echo "  3. Run workflow: clickstreamDataPreparation"
echo "  4. Verify processed files in S3"
